#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $max_processes = 5;
my $usage = "Usage: $script_name [options]
Runs ssl-check on any port in database which nmap thinks are SSL ports.

NB: ssl-check.pl is required to be in the path (part of yaptest).
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "ssl-check.pl ::IP:: ::PORT::",
	parallel_processes => 8,
	filter => { ssl => 1 },
	inactivity_timeout => 60,
	parser => 'yaptest-parse-ssl-check.pl'
);

