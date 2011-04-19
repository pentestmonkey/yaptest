#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use XML::Simple;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name nmap.xml [nmap.xml.2 ... ]
Read and nmap XML file and enters data into database.

";

my $y = yaptest->new();
my $commit = 1;
my $file = shift or die $usage;
my $xml_obj = XML::Simple->new;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	
	my @xml_strings;
	if (open (FILE, "<$file")) {
		local undef $/;
		my $xml_string = <FILE>;
                @xml_strings = map { /<.xml version="1.0".*?>/ . $_ } split /<.xml version="1.0".*?>/, $xml_string;
		foreach my $x (@xml_strings) {
			# Strip: <?xml-stylesheet href="file:///opt/local/share/nmap/nmap.xsl" type="text/xsl"?>
			$x =~ s/<\?xml-stylesheet .*?\?>//;
		}
		shift @xml_strings; # discard first element - empty
	} else {
		print "WARNING: Can't open $file for reading: $!.  Skipping.\n";
		next;
	}

	# <?xml version="1.0" ?>
	foreach my $xml_string (@xml_strings) {
		print "Processing new XML chunk\n";
		my $xml;
		eval {
			$xml = $xml_obj->XMLin($xml_string, KeyAttr => []);
		};
	
		if ($@) {
			print "WARNING: This XML chunks is corrupt.  Skipping.\n";
			next;
		}
		
		# print Dumper $xml;

		# Find scan time for UDP scan.  We'll store this data in host_info table.
		my $udp_start_time;
		my $udp_end_time;
		if (defined($xml->{taskbegin}) and ref($xml->{taskbegin}) eq "ARRAY") {
			foreach my $taskbegin_href (@{$xml->{taskbegin}}) {
				my $port_count = $taskbegin_href->{extrainfo};
				$udp_start_time = $taskbegin_href->{time} if (defined($taskbegin_href->{time}) and defined($taskbegin_href->{task}) and $taskbegin_href->{task} eq "UDP Scan");
			}
		} elsif (defined($xml->{taskbegin}) and ref($xml->{taskbegin}) eq "HASH") {
			my $taskbegin_href = $xml->{taskbegin};
			$udp_start_time = $taskbegin_href->{time} if (defined($taskbegin_href->{time}) and defined($taskbegin_href->{task}) and $taskbegin_href->{task} eq "UDP Scan");
		}

		if (defined($xml->{taskend}) and ref($xml->{taskend}) eq "ARRAY") {
			foreach my $taskend_href (@{$xml->{taskend}}) {
				my $port_count = $taskend_href->{extrainfo};
				if (defined($port_count)) {
					($port_count) = $port_count =~ /^(\d+) /;
					$udp_end_time = $taskend_href->{time} if (defined($taskend_href->{time}) and defined($taskend_href->{task}) and $taskend_href->{task} eq "UDP Scan" and defined($port_count) and $port_count > 1000 and $port_count < 2000 );
				}
			}
		} elsif (defined($xml->{taskend}) and ref($xml->{taskend}) eq "HASH") {
			my $taskend_href = $xml->{taskend};
			my $port_count = $taskend_href->{extrainfo};
			if (defined($port_count)) {
				($port_count) = $port_count =~ /^(\d+) /;
				$udp_end_time = $taskend_href->{time} if (defined($taskend_href->{time}) and defined($taskend_href->{task}) and $taskend_href->{task} eq "UDP Scan" and defined($port_count) and $port_count > 1000 and $port_count < 2000 );
			}
		}

		my $index = 0;
		# Process <host>...</host> section
		foreach my $host_href ((ref($xml->{host}) eq "ARRAY") ? @{$xml->{host}} : $xml->{host}) {
			# print Dumper $host_href;
			my $ip;
			my $mac;
	
			if (ref($host_href->{address}) eq "HASH") {
				$ip = $host_href->{address}->{addr};
			} elsif (ref($host_href->{address}) eq "ARRAY") {
				foreach my $addr_href (@{$host_href->{address}}) {
					$ip = $addr_href->{addr} if (defined($addr_href->{addrtype}) and $addr_href->{addrtype} eq "ipv4");
					$mac = $addr_href->{addr} if (defined($addr_href->{addrtype}) and $addr_href->{addrtype} eq "mac");
				}
			}
			
			unless (defined($ip)) {
				warn "ERROR: Can't extract ip address from XML\n";
				next;
			}
		
			if (defined($mac)) {
				print "PARSED: IP: $ip, MAC: $mac\n";
				$y->insert_ip_and_mac($ip, $mac);
			} else {
				print "PARSED: IP: $ip\n";
			}
	
			if (defined($udp_end_time) and defined($udp_start_time)) {
				my $udp_scan_time = $udp_end_time - $udp_start_time;
				print "PARSED: UDP Scan time: $udp_scan_time secs\n";
				$y->insert_host_info(ip_address => $ip, key => "nmap_quick_udp_scan_time", value => $udp_scan_time);
			}

			unless (ref($host_href->{ports}->{port}) eq "HASH" or ref($host_href->{ports}->{port}) eq "ARRAY") {
				print "WARNING: Host not processed.  No ports appear to be open / XML file corrupt.\n";
				next;
			}
	
			foreach my $port_href (ref($host_href->{ports}->{port}) eq "HASH" ? $host_href->{ports}->{port} : @{$host_href->{ports}->{port}}) {
	
				my $nmap_service_string = ($port_href->{service}->{product} || "") . " " . ($port_href->{service}->{version} || "") . " " . ($port_href->{service}->{extrainfo} ? "(" . $port_href->{service}->{extrainfo} . ")" : "");
				print "PARSED: $ip: " . ($port_href->{service}->{name} || "unknown") . " (" . $port_href->{portid} . "/" . $port_href->{protocol} . ") " . $port_href->{state}->{state} . " " . $nmap_service_string . "\n";
				if (lc($port_href->{state}->{state}) ne "open") {
					next;
				}
	
				unless (lc($port_href->{protocol}) eq 'tcp' or lc($port_href->{protocol}) eq 'udp') {
					print "WARNING: Ignoring protocol because it's not UDP or TCP\n";
					next;
				}
	
				$y->insert_port(ip => $ip, transport_protocol => $port_href->{protocol}, port => $port_href->{portid});
	
				$y->insert_port_info(
					ip                 => $ip,
					port               => $port_href->{portid},
					transport_protocol => $port_href->{protocol},
					port_info_key      => "nmap_service_version",
					port_info_value    => $nmap_service_string
				);
	
				$y->insert_port_info(
					ip                 => $ip,
					port               => $port_href->{portid},
					transport_protocol => $port_href->{protocol},
					port_info_key      => "nmap_service_name",
					port_info_value    => $port_href->{service}->{name} || "unknown"
				);

				if ($port_href->{service}->{name} eq "ssh" and $nmap_service_string =~ /.*\(protocol 1\.\d+\)$/i) {
					print "PARSED: Issue=sshv1_supported, IP=$ip, PORT=" . $port_href->{portid}. "\n";
					$y->insert_issue(name => "sshv1_supported", ip_address => $ip, port => $port_href->{portid}, transport_protocol => 'TCP');
				}
	
				if (defined($port_href->{service}->{tunnel})) {
					$y->insert_port_info(
						ip                 => $ip,
						port               => $port_href->{portid},
						transport_protocol => $port_href->{protocol},
						port_info_key      => "nmap_service_tunnel",
						port_info_value    => $port_href->{service}->{tunnel}
					);
				}
			}

			# insert OS guess
			my $os; 
			my $accuracy = -1;
			if (ref($host_href->{os}->{osmatch}) eq "HASH") {
				$os = $host_href->{os}->{osmatch}->{name};
				$accuracy = $host_href->{os}->{osmatch}->{accuracy};
				print "PARSED: OS=$os\n" if defined($os);
				print "PARSED: ACCURACY=$accuracy\n" if defined($accuracy);
			} elsif (ref($host_href->{os}->{osmatch}) eq "ARRAY") {
				foreach my $addr_href (@{$host_href->{os}->{osmatch}}) {
					$os = $addr_href->{name} if (defined($addr_href->{name}) and $addr_href->{accuracy} > $accuracy);
					$accuracy = $addr_href->{accuracy} if (defined($addr_href->{accuracy}) and $addr_href->{accuracy} > $accuracy);
				}
			}
			
			$y->insert_host_info(ip_address => $ip, key => "nmap_os_guess", value => $os) if defined($os);
			$y->insert_host_info(ip_address => $ip, key => "nmap_os_guess_accuracy", value => $accuracy) if (defined($os) and defined($accuracy) and $accuracy != -1);

			# insert topology info
			if (ref($host_href->{trace}->{hop}) eq "ARRAY") {
				my @hops = @{$host_href->{trace}->{hop}};
				foreach my $index (0..scalar(@hops) - 2) {
					if ($hops[$index]->{ipaddr} =~ /^\d+\.\d+\.\d+\.\d+$/ and $hops[$index + 1]->{ipaddr} =~ /^\d+\.\d+\.\d+\.\d+$/) {
						my $prev_ip = $hops[$index]->{ipaddr};
						my $ip = $hops[$index + 1]->{ipaddr};
						print "PARSED: Topology info $prev_ip->$ip\n";
						$y->insert_topology($prev_ip, $ip);
					}
				}
			}
		}
	}
}	
$y->{dbh}->commit if $commit;

