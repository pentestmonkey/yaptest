#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name --run
Runs nxscan on all hosts

NB: nxscan is required to be in the path.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command => "nxscan ::IP::",
	filter => { port => [135,139,445] },
	parallel_processes => 20,
	parser => 'yaptest-issues.pl parse'
);
