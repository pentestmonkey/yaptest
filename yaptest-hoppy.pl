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
Runs hoppy on any port in database which nmap thinks are HTTP(S) ports.

NB: hoppy v1.5+ is required to be in the path.  (http://labs.portcullis.co.uk/application/hoppy/)

";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "hoppy -h http://::IP:::::PORT::",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 0 },
	output_file => 'hoppy-http-::IP::-::PORT::.out',
	max_lines => 1000,
	inactivity_timeout => 180,
	parser => "yaptest-parse-hoppy.pl"
);

$y->run_test(
	command => "hoppy -h https://::IP:::::PORT::",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 1 },
	output_file => 'hoppy-https-::IP::-::PORT::.out',
	max_lines => 1000,
	inactivity_timeout => 180,
	parser => "yaptest-parse-hoppy.pl"
);


