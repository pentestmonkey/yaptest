#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name ssl-check-10.0.0.1-443.out [ ssl-check-10.0.0.2-443.out ]

Parses ssl-check output for security issues.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;
		if ($line =~ /\[\+\] Secure Renegotiaion is possible for (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})/) {
			my $ip = $1;
			my $port = $2;
			$y->insert_issue(name => "ssl_reneg_dos", ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}

		if ($line =~ /\[\+\] Insecure Renegotiaion is possible for (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):(\d{1,5})/) {
			my $ip = $1;
			my $port = $2;
			$y->insert_issue(name => "ssl_reneg_dos", ip_address => $ip, port => $port, transport_protocol => 'TCP');
			$y->insert_issue(name => "ssl_insec_reneg_mitm", ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}
	}
}
$y->commit;
$y->destroy;
