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
Runs xdpyinfo on TCP in the range 6000-6063.

NB: xdpyinfo is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "xdpyinfo -display ::IP:::::PORT-6000::",
	parallel_processes => $max_processes,
	output_file => "xdpyinfo-::IP::-::PORT::.out",
	filter => { port => "6000-6063" },
	max_lines => 1000,
	inactivity_timeout => 20
);

$y->run_test(
	command => "xwd -display ::IP:::::PORT-6000:: -root -out x-screenshot-::IP::-::PORT::.xwud",
	parallel_processes => $max_processes,
	output_file => "xwd-::IP::-::PORT::.out",
	filter => { port => "6000-6063" },
	max_lines => 1000,
	inactivity_timeout => 20
);
