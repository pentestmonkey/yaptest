#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs some misc tests on hosts in the backend database which
have port 53 UDP or TCP open.

NB: dig is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

# Recursive lookups (assuming host is connected to Internet)
$y->run_test(
	command => 'dig @::IP:: A google.com',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'dns-recursive-lookup-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-dns.pl'
);

$y->run_test(
	command => 'dig @::IP:: A localhost',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'dns-recursive-lookup-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-dns.pl'
);

$y->run_test(
	command => 'dig @::IP:: authors.bind chaos txt',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'dns-authors.bind-lookup-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-dns.pl'
);

$y->run_test(
	command => 'dig @::IP:: version.bind chaos txt',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'dns-version.bind-lookup-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-dns.pl'
);

$y->run_test(
	command => 'dig @::IP:: hostname.bind. chaos txt',
	filter => { port => 53, transport_protocol => 'udp' },
	output_file => 'dns-hostname.bind-lookup-::IP::.out',
	parallel_processes => 10,
	parser => 'yaptest-parse-dns.pl'
);

