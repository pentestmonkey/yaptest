#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;

do "yaptest-script-check.pl";
&check_programs("ntpq", "ntptrace");

use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs ntp tests on IPs in database with port 123/UDP open.

NB: ntptrace and ntpq are required to be in the path.
";

my $y = yaptest->new();

$y->run_test(
	command => "ntpq -c readvar -p ::IP::",
	filter => { port => 123, transport_protocol => 'udp'},
	parallel_processes => 12,
	output_file => "ntpq-readvar-::IP::.out",
	parser => "yaptest-parse-ntpq.pl"
);

$y->run_test(
	command => "ntptrace ::IP::",
	filter => { port => 123, transport_protocol => 'udp'},
	parallel_processes => 12,
	output_file => "ntpq-readvar-::IP::.out"
);

