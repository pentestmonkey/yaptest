#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $max_processes = 3;
my $script_name = basename($0);
my $usage = "Usage: $script_name [options]

[ WARNING: This is a work in progress.  It's not necessarily useful yet ]

Runs sidBuster on any port in database which have an
secured TNS listener (otherwise we already have the sids,
so there's no point in running sidBuster).

NB: sidBuster is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "sidBuster -b 2 -s 1 -e 3 -h ::IP:: -p ::PORT::",
	parallel_processes => $max_processes,
	filter => { port_info => "tns_listener_secure = yes", ssl => 0 },
	inactivity_timeout => 180,
	# parser => 'yaptest-parse-sidBuster.pl' TODO need to write this
);
