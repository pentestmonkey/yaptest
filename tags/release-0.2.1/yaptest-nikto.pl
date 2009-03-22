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
Runs nikto on any port in database which nmap thinks are HTTP(S) ports.

NB: nikto.pl is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "nikto.pl -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
	parallel_processes => $max_processes,
	output_file => "nikto-http-::IP::-::PORT::.out",
	filter => { port_info => "nmap_service_name like http", ssl => 0 },
	max_lines => 1000,
	inactivity_timeout => 300,
	parser => 'yaptest-parse-nikto.pl'
);

$y->run_test(
	command => "nikto.pl -ssl -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
	parallel_processes => $max_processes,
	output_file => "nikto-https-::IP::-::PORT::.out",
	filter => { port_info => "nmap_service_name like http", ssl => 1 },
	max_lines => 1000,
	inactivity_timeout => 300,
	parser => 'yaptest-parse-nikto.pl'
);


