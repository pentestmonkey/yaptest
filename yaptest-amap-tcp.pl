#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $max_processes = 5;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs amap on open TCP ports (found from backend database).

Amap is required to be in the path.
";
die $usage if shift;
my $commit = 1;
my $verbose = 1;
my $y = yaptest->new();

$y->run_test (
	command => "amap -b ::IP:: ::PORTLIST-SPACE::",
	filter => { transport_protocol => 'TCP' },
	parallel_processes => $max_processes,
	output_file => "amap-tcp-::IP::.out",
	inactivity_timeout => 90,
	parser => "yaptest-parse-amap.pl"
);

