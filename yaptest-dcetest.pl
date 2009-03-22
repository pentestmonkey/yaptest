#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs msrpc tests on IPs in database with port 135/TCP open.

NB: dcetest is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "dcetest ::IP::",
	filter => { port => 135, transport_protocol => 'tcp' },
	parallel_processes => 10,
	inactivity_timeout => 30,
	parser => "yaptest-parse-dcetest.pl"
);
