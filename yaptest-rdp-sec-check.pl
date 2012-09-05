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
Run rdp-sec-check.pl against TCP port 3389.

NB: rdp-sec-check.pl is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "rdp-sec-check.pl ::IP:::::PORT::",
	parallel_processes => $max_processes,
	filter => { port => 3389 },
	inactivity_timeout => 90
);
