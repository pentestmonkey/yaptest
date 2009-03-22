#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs a 'traceroute -n IP' and 'traceroute -I -n IP' on IPs in the backend database.

NB: traceroute is required to be in the path.
";

my $y = yaptest->new();
$y->check_root();

$y->run_test(
	command => "traceroute -n ::IP::",
	parallel_processes => 1,
	max_lines => 40,
	parser => "yaptest-parse-traceroute.pl"
);

$y->run_test(
	command => "traceroute -I -n ::IP::",
	output_file => 'traceroute-I-::IP::.out',
	parallel_processes => 1,
	max_lines => 40,
	parser => "yaptest-parse-traceroute.pl"
);

