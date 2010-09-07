#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs rup on IPs in database with the string 'rstatd'
in the output of rpcinfo -p.

NB: rup is required to be in the path.
";

my $y = yaptest->new();

$y->run_test(
	command => "rup ::IP::",
	filter => { port_info => 'rpcinfo_tcp like % 100001 %' },
	output_file => "rup-d-::IP::.out"
);
