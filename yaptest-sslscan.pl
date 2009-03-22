#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $max_processes = 5;
my $usage = "Usage: $script_name [options]
Runs sslscan on any port in database which nmap thinks are SSL ports.

NB: sslscan is required to be in the path (http://www.titania.co.uk/sslscan.php).
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "sslscan --xml=sslscan-::IP::-::PORT::.xml ::IP:::::PORT::",
	parallel_processes => 8,
	filter => { ssl => 1 },
	inactivity_timeout => 60,
	parser => 'yaptest-parse-sslscan.pl'
);

$y->run_test(
	command => "sslscan --starttls --xml=sslscan-::IP::-::PORT::.xml ::IP:::::PORT::",
	parallel_processes => 8,
	filter => { port_info => "bannergrab LIKE STARTTLS" },
	inactivity_timeout => 60,
	parser => 'yaptest-parse-sslscan.pl'
);
