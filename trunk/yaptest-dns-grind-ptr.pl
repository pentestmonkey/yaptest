#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs dns-grind to find PTR records for all IPs in database.

NB: dns-grind is required to be in the path.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command     => "dns-grind.pl -f ::IPFILE:: PTR",
	output_file => "dns-grind-ptr.out",
	parser      => "yaptest-parse-dns-grind-ptr.pl"
);
