#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name ike-scan.out [ ike-scan.out.2 ]

Parses ike-scan output for open ports.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	my $ip;
	print "Processing $filename ...\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;

		if ($line =~ /^(\d+\.\d+\.\d+\.\d+)\t/) {
			$ip = $1;
			$y->insert_port(ip => $ip, port => 500, transport_protocol => 'UDP');
		}
	}
}
$y->commit;
$y->destroy;
