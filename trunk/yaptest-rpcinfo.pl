#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs rpcinfo -p on IPs in database with port 111/TCP open.

NB: rpcinfo is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command            => "rpcinfo -p ::IP::",
	filter             => { port => 111, transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'rpcinfo-tcp-::IP::.out',
	parser             => "yaptest-parse-rpcinfo.pl"
);
