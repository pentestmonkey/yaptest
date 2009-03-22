#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs showmount -a and showmount -e on IPs in database with the string 'nfs'
in the output of rpcinfo -p.

NB: showmount is required to be in the path.
";

my $y = yaptest->new();

$y->run_test(
	command => "showmount -e ::IP::",
	filter => { port_info => 'rpcinfo_tcp like % 100003 %' },
	output_file => "showmount-e-::IP::.out"
);

$y->run_test(
	command => "showmount -a ::IP::",
	filter => { port_info => 'rpcinfo_tcp like % 100003 %' },
	output_file => "showmount-a-::IP::.out"
);

