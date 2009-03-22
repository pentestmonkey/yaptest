#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs a 'ping -R IP' on IPs in the backend database.

NB: ping is required to be in the path.
";

my $y = yaptest->new();

$y->run_test(
	command => "ping -c 2 -R -n ::IP::",
	parallel_processes => 10,
	max_lines => 40,
	output_file => "ping-r-::IP::.out",
	parser => 'yaptest-parse-ping-r.pl'
);

