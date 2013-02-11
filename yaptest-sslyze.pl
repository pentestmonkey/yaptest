#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs sslyze on any port in database which nmap thinks are SSL ports.

NB: sslyze.py is required to be in the path ( http://code.google.com/p/sslyze )
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "sslyze.py --timeout=30 --regular --tlsv1_1 --tlsv1_2 ::IP:::::PORT::",
	parallel_processes => 8,
	filter => { ssl => 1 },
	inactivity_timeout => 60,
#	parser => 'yaptest-parse-sslyze.pl'
);

