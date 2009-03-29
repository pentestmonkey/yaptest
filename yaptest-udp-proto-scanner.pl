#!/usr/bin/env perl
use warnings;
use strict;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs udp-proto-scanner.pl on all hosts (found from backend database).

udp-proto-scanner.pl is required to be in the path.
";
die $usage if shift;
my $commit = 1;
my $verbose = 1;
my $y = yaptest->new();

$y->run_test (
	command     => "udp-proto-scanner.pl -p all -f ::IPFILE::",
	output_file => "udp-proto-scanner.out",
	parser      => "yaptest-parse-udp-proto-scanner.pl"
);

