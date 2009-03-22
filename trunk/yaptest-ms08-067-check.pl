#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name --run
Runs ms08-067_check on all hosts that have port 445/TCP open.

NB: ms08-067_check is required to be in the path.
";

die $usage if shift;

my $y = yaptest->new();
$y->check_unsafe_ok();

$y->run_test(
	command => "ms08-067_check.py -t ::IP::",
	filter => { port => 445 },
	parallel_processes => 20,
	parser => 'yaptest-issues.pl parse'
);
