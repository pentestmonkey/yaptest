#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs 'nbtscan -v' on the IPs in the database

NB: nbtscan is required to be in the path.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command => "nbtscan -b 32000 -v -f ::IPFILE::",
	parser  => "yaptest-parse-nbtscan.pl"
);

# Get human-readable format too
$y->run_test(
	command => "nbtscan -h -b 32000 -v -f ::IPFILE::",
	output_file => 'nbtscan-human-readable.out'
);
