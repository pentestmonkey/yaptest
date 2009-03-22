#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $max_processes = 20;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs bannergrab on open UDP and TCP ports (found from backend database).

bannergrab is required to be in the path (http://www.titania.co.uk/bannergrab-ng.php).
";
die $usage if shift;
my $commit = 1;
my $verbose = 1;
my $y = yaptest->new();

$y->run_test (
	command => "bannergrab ::IP:: ::PORT::",
	filter => { transport_protocol => 'TCP' },
	output_file => 'bannergrab-tcp-::IP::-::PORT::.out',
	parallel_processes => $max_processes,
	inactivity_timeout => 90,
	parser => 'yaptest-parse-bannergrab.pl'
);

$y->run_test (
	command => "bannergrab --udp ::IP:: ::PORT::",
	filter => { transport_protocol => 'UDP' },
	output_file => 'bannergrab-udp-::IP::-::PORT::.out',
	parallel_processes => $max_processes,
	inactivity_timeout => 90,
	parser => 'yaptest-parse-bannergrab.pl'
);

