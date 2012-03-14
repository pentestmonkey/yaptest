#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs mop-check on each MAC Address in the local LAN.  Aim is to
identify hosts that might allow login over the MOP Remote Console
protocol.

Use linux client moprc to attempt login on hosts discovered:
# apt-get install latd
# moprc -v 00:11:22:33:44:55

This script needs to know the Network Interface to use.  This
is found from the 'yaptest_interface' config option:
\$ yaptest-config.pl query yaptest_interface
\$ yaptest-config.pl set yaptest_interface ath0

An IP address known to respond to ping is also required
\$ yaptest-config.pl query mop_src_mac
\$ yaptest-config.pl set mop_src_mac 22:44:66:88:aa:cc

The source MAC above is used by default.

NB: mop-check.py is required to be in the path.
";

die $usage if shift;
my $retries = 5;
my $commit = 1;
my $bandwidth = 200000;
my $verbose = 1;
my $y = yaptest->new();
my $interface = $y->get_config('yaptest_interface');
my $mop_src_mac = $y->get_config('mop_src_mac');

unless (defined($mop_src_mac)) {
	$mop_src_mac = "22:44:66:88:aa:cc";
}

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

unless (defined($interface)) {
	print "ERROR: Don't know which network interface to use.\n";
	die $usage;
}

print "$script_name is using network interface $interface and sending probes from $mop_src_mac.  See help message to reconfigure.\n";

$y->run_test (
	command     => "mop-check.py -I $interface -s $mop_src_mac -f ::MACFILE::",
	output_file => "mop-check.out",
	parser      => "yaptest-parse-mop-check.pl"
);
