#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

# Tool to find live hosts on a local network.

my $script_name = basename($0);
my $usage = "Usage: $script_name
ARP scans the local network.

This script needs to know the Network Interface to use.  This
is found from the 'yaptest_interface' config option:
\$ yaptest-config.pl query yaptest_interface
\$ yaptest-config.pl set yaptest_interface eth0

NB: This script relies on arp-scan being in the path
";

die $usage if shift;

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

# Read interface name
my $y = yaptest->new;
my $interface = $y->get_config('yaptest_interface');

unless (defined($interface)) {
	print "ERROR: Tell yaptest which interface using yaptest-config.pl.  See below.\n";
	die $usage;
}

my $retries = 2;
my $commit = 1;
my $verbose = 1;
my $arp_file = "arp-scan.out";

my $file = $y->run_command_save_output("arp-scan -r $retries -I $interface -l", $arp_file);
system("yaptest-parse-arp-scan.pl", $file);
