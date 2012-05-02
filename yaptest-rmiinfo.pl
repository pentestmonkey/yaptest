#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses rmiInfo on each port identified by nmap as running Java rmi.  To extract basic info out from the RMI service

NB: A script to run rmi. must be in your path.  You might need to create this!

For example
-----------------------
#!/bin/sh

java -jar <path to rmiInfo.jar> $1 $2

-----------------------

";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command     => 'rmiInfo ::IP:: ::PORT::',
	output_file => 'rmiInfo-::IP::-::PORT::.out',
	filter      => { port_info => "nmap_service_name = rmi"},
	parser      => "yaptest-parse-rmiinfo.pl"
);