#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs ssl-cipher-suite-enum on any port in database which nmap thinks are SSL ports.

NB: ssl-cipher-suite-enum.pl is required to be in the path ( http://labs.portcullis.co.uk/application/ssl-cipher-suite-enum/ )
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "ssl-cipher-suite-enum.pl  ::IP:::::PORT::",
	parallel_processes => 8,
	filter => { ssl => 1 },
	inactivity_timeout => 60,
#	parser => 'yaptest-parse-ssl-cipher-suite-enum.pl'
);

