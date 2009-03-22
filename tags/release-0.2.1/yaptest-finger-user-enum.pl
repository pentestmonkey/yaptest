#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $max_processes = 5;
my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs finger-user-enum.pl on any host which has 79/TCP open (in  the 
backend database).

A dictionary of file usernames is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_finger_usernames
\$ yaptest-config.pl set dict_finger_usernames /home/u/dicts/finger-users.txt

NB: finger-user-enum.pl is required to be in the path.
";

my $y = yaptest->new();
my $dictionary_file = $y->get_config('dict_finger_usernames');

unless (defined($dictionary_file)) {
        print "ERROR: No dictionary has been configured for finger-user-enum.pl.\n";
        die $usage;
}

die $usage if shift;

$y->run_test(
	command => "finger-user-enum.pl -U $dictionary_file -t ::IP::",
	parallel_processes => $max_processes,
	filter => { port => 79, transport_protocol => 'TCP' },
	max_lines => 110,
	inactivity_timeout => 300,
	parser => 'yaptest-parse-finger-user-enum.pl'
);
