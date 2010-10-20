#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs a ICMP scan of the IPs in the database

This script needs to know the Network Interface to use.  This
is found from the 'yaptest_interface' config option:
\$ yaptest-config.pl query yaptest_interface
\$ yaptest-config.pl set yaptest_interface ath0

NB: yaptest is required to be in the path.
";

die $usage if shift;
my $retries = 5;
my $commit = 1;
my $bandwidth = 200000;
my $verbose = 1;
my $y = yaptest->new();
my $interface = $y->get_config('yaptest_interface');

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

unless (defined($interface)) {
	print "ERROR: Don't know which network interface to use.\n";
	die $usage;
}

print "$script_name is using network interface $interface.  See help message to change interface name.\n";

$y->run_test (
	command     => "yapscan -sI -r $retries -i $interface -b $bandwidth -t - -f ::IPFILE::", 
	output_file => "yapscan-icmp.out",
	parser      => "yaptest-parse-yapscan-icmp.pl"
);

$y->{dbh}->commit if $commit;
