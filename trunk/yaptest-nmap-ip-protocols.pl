#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $max_processes = 5;
my $timeout_mins = 5;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs nmap IP Protocols scans (-sO) on all hosts in backend database.

WARNING: Scans taking longer than $timeout_mins mins will be terminated
         This may not be what you want.

Nmap is required to be in the path.
";
die $usage if shift;
my $commit = 1;
my $verbose = 1;
my $y = yaptest->new();

# Check we're root or we won't get anywhere
unless (geteuid == 0) {
	print "ERROR: You need to root to run this\n";
	exit 1;
}

$y->run_test (
	command => "nmap -sO -P0 -n -v -oA nmap-ip-protocols-::IP:: ::IP::",
	parallel_processes => $max_processes,
	timeout => $timeout_mins * 60,
	output_file => "nmap-ip-protocols-::IP::.out"
);

