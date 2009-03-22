#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name nikto-10.0.0.1-80.out [ nikto-10.0.0.2-80.out ]

Parses nikto output and adds issues to databases.  IP and port must be in the filename.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless ($filename =~ /(\d+\.\d+\.\d+\.\d+)-(\d+)/) {
		print "WARNING: Filename $filename doesn't contain an IP address and port.  Skipping...\n";
		next;
	}
	my $ip = $1;
	my $port = $2;
	print "IP: $ip, PORT: $port\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	my %issue;
	my $is_ssl = 0;
	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;

		# TODO:
		# WebDav
		# TRACE
		# Other HTTP methods
		# Need to detect if Nikto's producing false positives
		#
		
		if (
			$line =~ /^\+\s+OSVDB-3233:\s+GET\s+\/jsp-examples\// or
			$line =~ /^\+\s+OSVDB-3233:\s+GET\s+\/manager\/manager-howto.html/ or
			$line =~ /^\+\s+OSVDB-3233:\s+GET\s+\/manager\/html-manager-howto.html/ or
			$line =~ /^\+\s+OSVDB-3233:\s+GET\s+\/tomcat-docs\/index.html/
		) {
			$issue{tomcat_default_files} = 1;
			print "PARSED: tomcat_default_files\n";
		}
		
		if ($line =~ /^\+ Server: (.*?)\s*$/) {
			my $server = $1;
			unless ($server =~ /No banner retrieved/) {
				print "PARSED: HTTP Server header: $server\n";
	
				$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "http_server_header", port_info_value => $server);
			}
		}
		
		if ($line =~ /Retrieved X-Powered-By header: (.*?)\s*/) {
			my $x = $1;
			print "PARSED: X-Powered-By: $x\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "x_powered_by", port_info_value => $x);
		}

		if ($line =~ /^\+\s+SSL Info:\s+/) {
			$is_ssl = 1;
		}

		if ($is_ssl and $line =~ /ERROR: No auth credentials for "level_\d+_access/) {
			$issue{cisco_http_mgmt} = 1;
			print "PARSED: cisco_http_mgmt\n";
		}

		if ($line =~ /^\+ Server: Apache\/\d/) {
			$issue{apache_version_disclosed} = 1;
			print "PARSED: apache_version_disclosed\n";
		}

		if ($line =~ /^\+\s+OSVDB-637: GET .* - Enumeration of users is possible/) {
			$issue{apache_userdir} = 1;
			print "PARSED: apache_userdir\n";
		}

		if ($line =~ /^\+\s+OSVDB-3092: GET .status.full=true : Apache Tomcat and.or JBoss information page./) {
			$issue{jboss_status} = 1;
			print "PARSED: jboss_status\n";
		}
	}
	foreach my $issue (keys %issue) {
		$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => 'TCP');
	}
}
$y->commit;
$y->destroy;
