#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs tnscmd.pl with the ping, version, status and services option on
port that nmap thinks have service_name 'oracle-tns'.

NB: tnscmd.pl is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

for my $option ("ping", "version", "services", "status") {
        $y->run_test(
                command => "tnscmd -h ::IP:: -p ::PORT:: --rawcmd '(CONNECT_DATA=(COMMAND=$option))' --indent",
                filter => { port_info => [ "nmap_service_name = oracle-tns", "nmap_service_name = oracle" ], ssl => 0 },
                parallel_processes => 10,
                output_file => "tnscmd-$option-::IP::-::PORT::.out",
                timeout => 10,
                parser => 'yaptest-parse-tnscmd.pl'
        );
}
