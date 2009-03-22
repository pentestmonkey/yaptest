#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name dcetest.out [ dcetest.out.2 ]

Parses dcetest output for Windows hostnames.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	my $ip;
	print "Processing $filename ...\n";

        if ($file =~ /(\d+\.\d+\.\d+\.\d+)/) {
                $ip = $1;
        } else {
                print "ERROR: The name of file $file doesn't contain an IP and port.  Ignoring.\n";
                next;
        }

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;

		# Parse hostname
		if ($line =~ /ncacn_np:\\\\(.*)\[\\PIPE\\/) {
			my $hostname = $1;
			print "PARSED: Hostname=$hostname\n";
			$y->insert_hostname(type => 'windows_hostname', ip_address => $ip, hostname => $hostname);
		}

	}
}
$y->commit;
$y->destroy;
