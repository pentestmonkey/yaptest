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
Runs web-check.pl on any port in database which nmap thinks are HTTP(S) ports.

NB: web-check.pl is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "web-check.pl http://::IP:::::PORT::/",
	parallel_processes => $max_processes,
	output_file => "web-check-http-::IP::-::PORT::.out",
	filter => { port_info => "nmap_service_name like http", ssl => 0 },
	max_lines => 3000,
	inactivity_timeout => 60,
	parser => 'yaptest-parse-web-check.pl'
);

$y->run_test(
	command => "web-check.pl https://::IP:::::PORT::/",
	parallel_processes => $max_processes,
	output_file => "web-check-https-::IP::-::PORT::.out",
	filter => { port_info => "nmap_service_name like http", ssl => 1 },
	max_lines => 3000,
	inactivity_timeout => 60,
	parser => 'yaptest-parse-web-check.pl'
);
