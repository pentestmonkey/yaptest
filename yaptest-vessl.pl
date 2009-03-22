#!/usr/bin/env perl
# Contributed by deanx.
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $max_processes = 5;
my $usage = "Usage: $script_name [options]
Runs vessl on any port in database which nmap thinks are SSL ports.

Ensure that you have your CA certs installed in /etc/certs/mozilla.pem in 
order to get the most meaningful issues from vessl.  Yaptest may allow you
to specify a different location for your PEM file in a later release.

NB: vessl is required to be in the path (http://labs.portcullis.co.uk/application/vessl).
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "vessl -v -h ::IP:: -p ::PORT::",
	parallel_processes => 8,
	filter => { ssl => 1 },
	parser => "yaptest-parse-vessl.pl"
);

$y->run_test(
	command => "vessl -v -h ::IP:: -p ::PORT::",
	filter => { port_info => "bannergrab LIKE STARTTLS" },
	parallel_processes => 8,
	parser => "yaptest-parse-vessl.pl"
);
