#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs gateway-finder on each MAC Address in the local LAN.  Aim is to
identify hosts with IP forwarding enabled, gateways to Internet.

This script needs to know the Network Interface to use.  This
is found from the 'yaptest_interface' config option:
\$ yaptest-config.pl query yaptest_interface
\$ yaptest-config.pl set yaptest_interface ath0

An IP address known to respond to ping is also required
\$ yaptest-config.pl query ping_ip
\$ yaptest-config.pl set ping_ip 173.194.34.133

The above IP (a google.com address) is used by default.

NB: gateway-finder.py is required to be in the path.
";

die $usage if shift;
my $retries = 5;
my $commit = 1;
my $bandwidth = 200000;
my $verbose = 1;
my $y = yaptest->new();
my $interface = $y->get_config('yaptest_interface');
my $ping_ip = $y->get_config('ping_ip');

unless (defined($ping_ip)) {
	# This is google.com address - should configure ip of choice locally with something known to respond to ping
	$ping_ip = "173.194.34.133";
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

print "$script_name is using network interface $interface and attempt to reach host $ping_ip on the Internet.  See help message to reconfigure.\n";

$y->run_test (
	command     => "gateway-finder.py -I $interface -i $ping_ip -f ::MACFILE::",
	output_file => "gateway-finder.out",
	parser      => "yaptest-parse-gateway-finder.pl"
);
