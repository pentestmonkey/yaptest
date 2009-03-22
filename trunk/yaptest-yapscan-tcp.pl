#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $scan_type = "full";
my $portfile;
my $portlist;
my $usage = "Usage: $script_name [ veryquick | quick | full | n-m,o,p | file ]
Performs a TCP SYN scan of the IPs in the database.

This script needs to know the Network Interface to use.  This
is found from the 'yaptest_interface' config option:
\$ yaptest-config.pl query yaptest_interface
\$ yaptest-config.pl set yaptest_interface ath0

The following scan types are supported:
	veryquick Scan around 100 common ports
	quick     Scan around 1400 common ports
	full      Scan all 65535 ports (default)
	n-m,o,p   Custom portlist, e.g. 1-1000,3128,8000-8100
	file      Custom portlist from file.  One port per line.

NB: yapscan is required to be in the path.
";

my $type_arg = shift;
if (defined($type_arg)) {
	if ($type_arg eq "veryquick" or $type_arg eq "quick" or $type_arg eq "full") {
		$scan_type = $type_arg;
	} elsif ($type_arg =~ /^\d+[\d,-]+$/) {
		$portlist = $type_arg;
		$scan_type = "custom_range";
	} elsif ($type_arg =~ /^[a-zA-Z0-9\/\._,~-]+$/ and open PORTFILE, "<$type_arg") {
		$portfile = $type_arg;
		$scan_type = "custom_file";
		close PORTFILE;
	} else {
		print "ERROR: Illegal scan type $type_arg selected.\n";
		die $usage;
	}
}
die $usage if shift;

my $tcp_retries = 2;
my $commit = 1;
my $bandwidth = 1000000;
my $tcp_quick_file = "yapscan-tcp.out";

my %ports;
my %live_ip;
my $verbose = 1;
my $y = yaptest->new();
my $interface = $y->get_config('yaptest_interface');

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

print "$script_name is using network interface $interface.  See help message to change interface name.\n";

if ($scan_type eq "custom_range") {
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p $portlist -f ::IPFILE::", 
		output_file => "yapscan-tcp-custom-range.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
}

if ($scan_type eq "custom_file") {
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -P $portfile -f ::IPFILE::", 
		output_file => "yapscan-tcp-custom-file.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
}

if ($scan_type eq "veryquick") {
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -P common -f ::IPFILE::", 
		output_file => "yapscan-tcp-veryquick.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
}

if ($scan_type eq "quick") {
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -P known -f ::IPFILE::", 
		output_file => "yapscan-tcp-quick.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
}

if ($scan_type eq "full") {
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 1-8192 -f ::IPFILE::", 
		output_file => "yapscan-tcp-1-8192.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 8193-16384 -f ::IPFILE::", 
		output_file => "yapscan-tcp-8193-16384.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 16385-24576 -f ::IPFILE::", 
		output_file => "yapscan-tcp-16385-24576.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 24577-32768 -f ::IPFILE::", 
		output_file => "yapscan-tcp-24577-32768.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 32769-40960 -f ::IPFILE::", 
		output_file => "yapscan-tcp-32769-40960.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 40961-49152 -f ::IPFILE::", 
		output_file => "yapscan-tcp-40961-49152.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 49153-57344 -f ::IPFILE::", 
		output_file => "yapscan-tcp-49153-57344.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
	
	$y->run_test (
		command     => "yapscan -sS -r $tcp_retries -i $interface -b $bandwidth -p 57345-65535 -f ::IPFILE::", 
		output_file => "yapscan-tcp-57345-65536.out",
		parser      => "yaptest-parse-yapscan-tcp.pl"
	);
}

$y->{dbh}->commit if $commit;
