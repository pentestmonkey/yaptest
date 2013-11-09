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
Runs web-screenshot.js on any port in database which nmap thinks are HTTP(S) ports.

NB: web-screenshot.js is required to be in the path (which in turn depends on phantomjs).
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "web-screenshot.js http://::IP:::::PORT:: web-screenshot-http-::IP::-::PORT::.png",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 0 },
	inactivity_timeout => 300
);

$y->run_test(
	command => "web-screenshot.js https://::IP:::::PORT:: web-screenshot-https-::IP::-::PORT::.png",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 1 },
	inactivity_timeout => 300
);


