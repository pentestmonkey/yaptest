#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs fpdns against servers that have port 53 UDP or TCP open.

NB: fpdns is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

# Recursive lookups (assuming host is connected to Internet)
$y->run_test(
	command => 'fpdns ::IP::',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'fpdns-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-fpdns.pl'
);

