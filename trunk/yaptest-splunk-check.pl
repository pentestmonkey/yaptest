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
Run splunk-check.pl against TCP ports 8000 and 8089/TCP.

NB: splunk-check.pl is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "splunk-check.pl http://::IP:::::PORT::",
	output_file => "splunk-check-http-::IP::-::PORT::.out",
	parallel_processes => $max_processes,
	filter => { port => 8000 },
	inactivity_timeout => 30,
	parser => 'yaptest-parse-splunk-check.pl'
);

$y->run_test(
	command => "splunk-check.pl https://::IP:::::PORT::",
	output_file => "splunk-check-https-::IP::-::PORT::.out",
	parallel_processes => $max_processes,
	filter => { port => 8000 },
	inactivity_timeout => 30,
	parser => 'yaptest-parse-splunk-check.pl'
);

$y->run_test(
	command => "splunk-check.pl https://::IP:::::PORT::",
	output_file => "splunk-check-https-::IP::-::PORT::.out",
	parallel_processes => $max_processes,
	filter => { port => 8089 },
	inactivity_timeout => 30,
	parser => 'yaptest-parse-splunk-check.pl'
);
