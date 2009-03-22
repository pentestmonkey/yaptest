#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $scan_type = "full";
my $max_processes = 5;
my $portfile;
my $portlist;
my $usage = "Usage: $script_name [ quick | full | openonly | n-m,o,p ]
Performs a TCP SYN scan of the IPs in the database.

The following scan types are supported:
	quick     Scan around 1400 common ports
	full      Scan all 65535 ports (default)
	openonly  Scan only the TCP ports that are recorded
	          as Open in the backend database.
	n-m,o,p   Custom portlist, e.g. 1-1000,3128,8000-8100

NB: nmap is required to be in the path.
";

my $type_arg = shift;
if (defined($type_arg)) {
	if ($type_arg eq "quick" or $type_arg eq "full" or $type_arg eq "openonly") {
		$scan_type = $type_arg;
	} elsif ($type_arg =~ /^\d+[\d,-]+$/) {
		$portlist = $type_arg;
		$scan_type = "custom_range";
	} else {
		print "ERROR: Illegal scan type $type_arg selected.\n";
		die $usage;
	}
}
die $usage if shift;

my $commit = 1;
my %ports;
my %live_ip;
my $verbose = 1;
my $y = yaptest->new();

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

if ($scan_type eq "custom_range") {
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-custom.out -p $portlist ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-custom.out",
	);
}

if ($scan_type eq "quick") {
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-quick.out ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-quick.out",
	);
}

if ($scan_type eq "full") {
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-1-8192.out -p 1-8192 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-1-8192.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-8193-16384.out -p 8193-16384 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-8193-16384.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-16385-24576.out -p 16385-24576 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-16385-24576.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-24577-32768.out -p 24577-32768 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-24577-32768.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-32769-40960.out -p 32769-40960 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-32769-40960.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-40961-49152.out -p 40961-49152 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-40961-49152.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-49153-57344.out -p 49153-57344 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-49153-57344.out",
	);
	
	$y->run_test (
		command     => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::-57345-65536.out -p 57345-65535 ::IP::",
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-57345-65536.out",
	);
}

if ($scan_type eq "openonly") {
	$y->run_test (
		command => "nmap -sS -P0 -n -O -v -A --version-all --append_output -oA nmap-tcp-::IP::.out -p ::PORTLIST:: ::IP::",
		filter => { transport_protocol => 'TCP' },
		parallel_processes => $max_processes,
		output_file => "nmap-tcp-::IP::-openonly.out"
	);
}

$y->{dbh}->commit if $commit;
