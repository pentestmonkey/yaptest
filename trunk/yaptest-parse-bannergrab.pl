#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name bannergrab-tcp-1.2.3.4-80.out [ bannergrab-udp-1.2.3.5-53.out ... ]
Reads output of bannergrab and enters data into database.  The filename should
contain the IP address and TCP port.
";

die $usage if $help;
my $file = shift or die $usage;
my $y = yaptest->new();
my $commit = 1;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	my ($transport_protocol, $current_ip, $current_port) = $file =~ /(tcp|udp)-(\d+\.\d+\.\d+\.\d+)-(\d+)/;
	unless (defined($transport_protocol) and defined($current_ip) and defined($current_port)) {
		print "ERROR: Filename $file doesn't contain a transport protocol, an IP and port.  Ignoring.\n";
		next;
	}
	unless (open (BGFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	undef $/;
	my $bannergrab = <BGFILE>;
	$y->insert_port(ip => $current_ip, transport_protocol => $transport_protocol, port => $current_port);
	$y->insert_port_info(
		ip                 => $current_ip,
		port               => $current_port,
		transport_protocol => $transport_protocol,
		port_info_key      => "bannergrab",
		port_info_value    => $bannergrab
	);

	# Usernames from finger
	if (my @usernames = $bannergrab =~ /\nLogin:\s+(\S+)\s+Name:\s+\S/g) {
		foreach my $username (@usernames) {
			print "PARSED: Username $username\n";
			$y->insert_credential(ip_address => $current_ip, username => $username, credential_type_name => "os_unix");
		}
	}

	# Hostname from SMTP
	if (my ($hostname) = $bannergrab =~ /^220\s+(\S+)\s+ESMTP/) {
		print "PARSED: Hostname $hostname\n";
		$y->insert_hostname(type => 'smtp_hostname', ip_address => $current_ip, hostname => $hostname);
	}
}
$y->{dbh}->commit if $commit;
