#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs ike-scan on the IPs in the database

NB: ike-scan is required to be in the path.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command => "ike-scan -f ::IPFILE::",
	parser => "yaptest-parse-ike-scan.pl"
);
