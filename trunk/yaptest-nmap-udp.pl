#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $max_processes = 10;
my $timeout = 560; # secs
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs nmap UDP scan on all hosts (found from backend database).

WARNING: Scans taking longer than $timeout secs will be terminated
         This may not be what you want.

Nmap is required to be in the path.
";
die $usage if shift;
my $commit = 1;
my $verbose = 1;
my $y = yaptest->new();
$y->check_root();

my $t = $y->get_config('nmap_udp_timeout');

if (defined($t)) {
	$timeout = $t;
}

print "Note: Timeout set to $timeout secs.  Change this by using yaptest-config.pl\n";
print "      to set 'nmap_udp_timeout' to a different value.\n";

$y->run_test (
	command => "nice nmap -sU -P0 -n -O -v -oA nmap-udp-::IP::.out ::IP::",
	parallel_processes => $max_processes,
	timeout => $timeout,
	output_file => "nmap-udp-::IP::.out"
);

# We'll also run a full UDP scan if the quick UDP scan finished in less than 10 secs
# This is often the case for Windows boxes (XP and prior) which don't limit the rate
# at which they send ICMP Port Unreachable messages.
$y->run_test (
	command => "nice nmap -sU -p- -P0 -n -O -v -oA nmap-udp-full-::IP::.out ::IP::",
	filter => { host_info => 'nmap_quick_udp_scan_time < 10' },
	parallel_processes => $max_processes,
	timeout => $timeout,
	output_file => "nmap-udp-full-::IP::.out"
);

$y->run_test (
	command => "nice nmap -sU -P0 -n -O -v -A --version-all --append_output -oA nmap-udp-::IP::-openonly.out -p ::PORTLIST:: ::IP::",
	filter => { transport_protocol => 'UDP' },
	parallel_processes => $max_processes,
	timeout => $timeout,
	output_file => "nmap-udp-::IP::-openonly.out"
);

