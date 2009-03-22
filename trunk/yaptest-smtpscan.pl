#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $max_processes = 5;
my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs smtpscan on any port in database with is 25/TCP.

NB: smtpscan is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "smtpscan -i 60 ::IP::",
	parallel_processes => $max_processes,
	filter => { port => 25, transport_protocol => 'tcp' },
	max_lines => 1000,
	inactivity_timeout => 300
);
