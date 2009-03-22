#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $max_processes = 5;
my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs oscanner on any port in database which nmap thinks are oracle-tns ports.

NB: oscanner is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "oscanner -s ::IP:: -P ::PORT::",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name = oracle-tns", ssl => 0 },
	max_lines => 4000,
	inactivity_timeout => 60,
	parser => 'yaptest-parse-oscanner.pl'
);
