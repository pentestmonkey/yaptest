#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name tnscmd-10.0.0.1-1521.out [ tnscmd-10.0.0.2-1521.out ]

Parses tnscmd output and adds issues to databases.  IP and port must be in the filename.
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

	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;

		if ($line =~ /Version\s+(\d+\.\d+\.\d+\.\d+.\d+)\s+-\s+/) {
			my $version = $1;
			print "PARSED: version $version\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_version", port_info_value => $version);
		}
		
		if ($line =~ /TNSLSNR for ([^:]+)?: Version/) {
			my $os = $1;
			print "PARSED: OS $os\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_os", port_info_value => $os);
		}
		
		if ($line =~ /ORACLE_HOME=([^,]+),/) {
			my $home = $1;
			print "PARSED: Home $home\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_home", port_info_value => $home);
		}

		if ($line =~ /ORACLE_SID=([^,\s']+)/) {
			my $sid = $1;
			print "PARSED: SID $sid\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_sid", port_info_value => $sid);
		}

		if ($line =~ /SERVICE_NAME=([^,\s']+)/) {
			my $sid = $1;
			print "PARSED: SID $sid\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_sid", port_info_value => $sid);
		}
		if ($line =~ /^\s+LOGFILE=(\S+?)\s*$/) {
			my $log_file = $1;
			print "PARSED: Log file $log_file\n";

			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "oracle_tns_log_file", port_info_value => $log_file);
			$y->insert_issue(name => "oracle_no_tns_password", ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}

	}
}
$y->commit;
$y->destroy;
