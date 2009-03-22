#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $max_processes = 5;
my $usage = "Usage: $script_name [options]
Runs ssh-keyscan on any port in database which nmap thinks are SSH ports.

NB: ssh-keyscan is required to be in the path
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "ssh-keyscan -p ::PORT:: -t rsa,rsa1,dsa ::IP::",
	parallel_processes => 8,
	filter => { port_info => "nmap_service_name = ssh" },
	parser => 'yaptest-parse-ssh-keyscan.pl'
);
