#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name dns-grind.out [ dns-grind.out.2 ]

Parses dns-grind output for dns hostnames.
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
		print;
		chomp;
		my $line = $_;

		# NetBIOS Name Table for Host 10.0.0.1:
		if ($line =~ /(\d+\.\d+\.\d+\.\d+)\t(.*)/) {
			my $ip = $1;
			my $hostname = $2;
			$hostname =~ s/\x0d//g;
			print "PARSED: IP=$ip, HOST=$hostname\n";
			$y->insert_hostname(type => 'dns_ptr', ip_address => $ip, hostname => $hostname);
		}
	}
}
$y->commit;
$y->destroy;
