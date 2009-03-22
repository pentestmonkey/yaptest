#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs sshprobe on each port identified as SSH by nmap.

NB: sshprobe is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "sshprobe ::IP:: ::PORT::",
	filter => { port_info => "nmap_service_name = ssh" },
	timeout => 20,
	parallel_processes => 10
);
