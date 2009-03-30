#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use Data::Dumper;
use File::Basename;

my $script_name = basename($0);
my $usage = "
Usage: $script_name query [ --ip ip ] [ -p port ] [ --trans tcp|udp ] [ --issue name ] [ --test test_area ]
       $script_name export out.xml [ --ip ip ] [ -p port ] [ --trans tcp|udp ] [ --issue name ] [ --test test_area ]
       $script_name parse file [ file ... ]
       $script_name add --issue name -i ip [ -p port --trans tcp|udp ]
       $script_name delete --issue name -i ip [ -p port --trans tcp|udp ]
       $script_name insecgen

query mode:
	Display issues related to hosts or ports from the backend database.

export mode:
	Save the query output to an XML file.

parse mode
	Attempts to automatically parse a file and extract security issues.
	Currently parses nessus nbe files for a few exploitable issues and
	the output of nxscan and tnscmd.pl.
	If a nessus html file is passed, this won't be parsed for issues, 
	but will be stored in the database.

add mode:
	Associate an issue with a host or port.

delete mode:
	Un-Associate an issue with a host or port.  It is recommended that you
	ALWAYS specify an issue name.  It's not manditatory though, and it IS
	possible to delete all the issues for a host, or even simply delete
	ALL the issues.

insecgen:
        Generate issues about insecure protocols (current test area only).
";

my $test_area;
my $issue;
my $ip;
my $port;
my $trans;
my %good_issue = (
	"10657" => "MS01-023",
	"11412" => "MS03-007",
	"11835" => "MS03-039",
	"11890" => "MS03-043",
	"11921" => "MS03-049",
	"12054" => "MS04-007",
	"12209" => "MS04-011",
	"15456" => "MS04-031",
	"18489" => "MS05-030",
	"19408" => "MS05-039",
	"20382" => "MS06-001",
	"21193" => "MS05-047",
	"21210" => "MS06-013",
	"21689" => "MS06-025",
	"22034" => "MS06-035",
	"22194" => "MS06-040",
	"22536" => "MS06-063",
	"23643" => "MS06-066",
	"24323" => "telnet_fuser",
	"29308" => "MS07-064",
	"21564" => "vnc_auth_bypass",
	"10114" => "icmp_timestamp",
	"12295" => "dell_openmanage",
	"10674" => "mssql_version_udp",
	"10539" => "dns_recursive",
	"11819" => "tftp_insecure",
	"10884" => "ntp_os_info",
	"18405" => "rdp_mitm",
	"26928" => "ssl_weak_ciphers",
	"15901" => "expired_ssl_cert",
	"10150" => "nbt_info",
	"10785" => "smb_os_info",
	"10397" => "windows_browse_list",
	"26920" => "smb_null_session",
	"11424" => "webdav_enabled",
	"10722" => "ldap_null_base_dn",
	"10245" => "rsh_insecure",
	"20007" => "sslv2_supported",
	"32397" => "epo_version",
	"25702" => "epo_code_exec",
	"10281" => "insec_proto_telnet",
	"32314" => "weak_ssh_host_key",
	"19948" => "x11_open",
	"10860" => "win_rid_cycle",
);
GetOptions (
	"test_area=s" => \$test_area,
	"trans=s" => \$trans,
	"ip=s" => \$ip,
	"issue=s" => \$issue,
	"port=s" => \$port,
);

my $command = shift or die $usage;

my $y = yaptest->new();
if ($command eq "parse") {
	my $file = shift or die $usage;
	unshift @ARGV, $file;
	while (my $filename = shift) {
		my $ip;
		print "Processing $filename ...\n";
	
		unless (open(FILE, "<$filename")) {
			print "WARNING: Can't open $filename for reading.  Skipping...\n";
			next;
		}

		# slurp nessus html into database
		if ($filename =~ /nessus-report-(\d+\.\d+\.\d+\.\d+).html/) {
			my $ip = $1;
			if (open HTML, "<$filename") {
				local undef $/;
				my $html = <HTML>;
				$html =~ s/10pt/11pt/g;
				$html =~ s/8pt/10pt/g;
				$y->insert_host_info(ip_address => $ip, key => "nessus_html_report", value => $html);
			} else {
				print "ERROR: Couldn't open nessus html file $filename for reading: $!. Skipping.\n";
			}
			next;
		}
	
		while (<FILE>) {
			print;
			chomp;
			my $line = $_;
	
			# nxscan
			# 1.2.3.4 03 OS[Windows 5.0] MS04-007 VULNERABLE, MS04-011 VULNERABLE, MS06-040 INCONCLUSIVE [00000000]
			if ($filename =~ /nxscan/ and $line =~ /^(\d+\.\d+\.\d+\.\d+) [0-9a-fA-F]{2} OS\[[^]]*\] (MS[0-9]{2}-[0-9]{3}.*MS[0-9]{2}-[0-9]{3}.*MS[0-9]{2}-[0-9]{3}.*)/) {
				my $ip = $1;
				my $result = $2;
				my @results = split ", ", $result;
				foreach my $r (@results) {
					if ($r =~ /(MS[0-9]{2}-[0-9]{3}) VULNERABLE/) {
						my $issue = $1;
						print "PARSED: IP=$ip, ISSUE=$issue\n";
						$y->insert_issue(name => $issue, ip_address => $ip);
					}
				}
			}

			# ms08-067_check
			# 1.2.3.4: VULNERABLE
			if ($filename =~ /ms08-067/ and $line =~ /^(\d+\.\d+\.\d+\.\d+): VULNERABLE/) {
				my $ip = $1;
				my $issue = "MS08-067";
				print "PARSED: IP=$ip, ISSUE=$issue\n";
				$y->insert_issue(name => $issue, ip_address => $ip);
			}

			# nessus
			# results|1.2.3|1.2.3.4|telnet (23/tcp)|24323|Security Hole|\nSynopsis
			if ($filename =~ /(?:nessus|\.nbe)/ and $line =~ /^results\|[\d\.]+\|(\d+\.\d+\.\d+\.\d+)\|.*?\((\d+)\/(tcp|udp)\)\|(\d+)\|Security[^|]+\|(.*)/) {
				my $ip = $1;
				my $port = $2;
				my $trans = uc $3;
				my $ness_id = $4;
				my $issue_text = $5;

				# Only parse the SSL cipher issue if ciphers are weak
				if ($ness_id eq '26928') {
					next unless ($issue_text =~ /\(40\)|\(56\)|/);
				}

				# Only parse the NTP issue if it actually leaks OS info
				if ($ness_id eq '10884') {
					next unless $issue_text =~ /system=/;
				}

				if (defined($good_issue{$ness_id})) {
					print "PARSED: $ip:$port/$trans issue $ness_id (" . $good_issue{$ness_id} . ")\n";
					$y->insert_issue(name => $good_issue{$ness_id}, ip_address => $ip, port => $port, transport_protocol => $trans);
				}
			}

			# results|1.2.3|1.2.3.4|general/icmp|10114|Security Note|
			if ($filename =~ /(?:nessus|\.nbe)/ and $line =~ /^results\|[\d\.]+\|(\d+\.\d+\.\d+\.\d+)\|general\/icmp\|(\d+)\|Security Note\|.*/) {
				my $ip = $1;
				my $ness_id = $2;
				if (defined($good_issue{$ness_id})) {
					print "PARSED: $ip issue $ness_id (" . $good_issue{$ness_id} . ")\n";
					$y->insert_issue(name => $good_issue{$ness_id}, ip_address => $ip);
				}
			}

			# FScan
			if ($filename =~ /fscan/ and $line =~ /^"(\d+\.\d+\.\d+\.\d+)",[^,]+,[^,]+,[^,]+,"(MS\d\d-\d\d\d)","Vulnerable"/) {
				my $ip = $1;
				my $issue = $2;
				print "PARSED: $ip: issue=$issue\n";
				$y->insert_issue(name => $issue, ip_address => $ip);
			}

			# insec tns listener
			if ($line =~ /^\s+LOGFILE=/) {
				if ($filename =~ /tns.*?(\d+\.\d+\.\d+\.\d+)/) {
					my $ip = $1;
					print "PARSED: $ip: issue=tns-listener\n";
					$y->insert_issue(name => "tns-listener", ip_address => $ip);
				}
			}
		}
	}
} elsif ($command eq "query" or $command eq "export") {
	my $aref = $y->get_issues(test_area_name => $test_area, ip_address => $ip, port => $port, issue => $issue);
	if ($command eq "query") {
		$y->print_table_hashes($aref, undef, qw(test_area_name ip_address port transport_protocol_name issue_shortname));
	}
	if ($command eq "export") {
		my $filename = shift or die "ERROR: Filename argument is mandatory for 'export'\n";
		$y->export_to_xml($aref, "issues", $filename);
		print "XML output of query saved to $filename\n";
	}
} elsif ($command eq "add") {
	unless (defined($issue) and defined($ip)) {
		die "ERROR: --issue and --ip options are mandatory for 'add' mode\n";
	}
	$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => $trans);
	print "Associated issue $issue with IP $ip\n";
} elsif ($command eq "delete") {
	my $error = shift;
	if (defined($error)) {
		print "ERROR: Too many arguments passed.  Aborting.\n";
		exit 1;
	}
	print "Deleting issues... \n\n";
	$y->delete_issues(test_area => $test_area, ip_address => $ip, issue => $issue);
	print "Issues deleted successfully\n";
} elsif ($command eq "insecgen") {
	my $arefs;
	# FTP
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 21, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_ftp', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_ftp", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# telnet
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 23, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_telnet', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_telnet", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# smc
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 898, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_smc', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_smc", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# XDMCP
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 177, transport_protocol => 'UDP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_xdmcp', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_xdmcp", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# tftp
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 69, transport_protocol => 'UDP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_tftp', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_tftp", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}
	
	# rexec
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 512, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_rexec', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_rexec", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# rlogin
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 513, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_rlogin', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_rlogin", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# rsh
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 514, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_rsh', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "insec_proto_rsh", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# rdp 
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 3389, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'rdp_mitm', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(name => "rdp_mitm", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# snmpv1
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 161, transport_protocol => 'UDP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'insec_proto_snmp1', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(test_area => $href->{test_area_name}, name => "insec_proto_snmp1", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# finger
	$arefs = $y->get_ports(test_area => $y->get_test_area, port => 79, transport_protocol => 'TCP');
	foreach my $href (@$arefs) {
		print "DEBUG: name => 'finger_user_enum', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
		$y->insert_issue(test_area => $href->{test_area_name}, name => "finger_user_enum", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
	}

	# small services
	foreach my $port (7, 9, 13, 19, 37) {
		foreach my $trans ("UDP", "TCP") {
			$arefs = $y->get_ports(test_area => $y->get_test_area, port => $port, transport_protocol => $trans);
			foreach my $href (@$arefs) {
				print "DEBUG: name => 'small_services', ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol}\n";
				$y->insert_issue(test_area => $href->{test_area_name}, name => "small_services", ip_address => $href->{ip_address}, port => $href->{port}, transport_protocol => $href->{transport_protocol});
			}
		}
	}
} else {
	print "ERROR: Command $command not implemented\n";
}
$y->commit;
$y->destroy;

