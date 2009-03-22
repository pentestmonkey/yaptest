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
Runs smtp-user-enum.pl on any port in database which bannergrab identified
as being vulnerable to user enumeration through the VRFY command.

A dictionary of file usernames is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_smtp_usernames
\$ yaptest-config.pl set dict_smtp_usernames /home/u/dicts/smtp-users.txt

NB: smtp-user-enum.pl is required to be in the path.
";

my $y = yaptest->new();
my $dictionary_file = $y->get_config('dict_smtp_usernames');

unless (defined($dictionary_file)) {
        print "ERROR: No dictionary has been configured for smtp-user-enum.pl.\n";
        die $usage;
}

die $usage if shift;

$y->run_test(
	command => "smtp-user-enum.pl -M VRFY -U $dictionary_file -t ::IP:: -p ::PORT::",
	parallel_processes => $max_processes,
	filter => { port_info => "bannergrab like 550 %bannergrab123... User unknown", ssl => 0 },
	max_lines => 110,
	inactivity_timeout => 25,
	parser => 'yaptest-parse-smtp-user-enum.pl'
);
