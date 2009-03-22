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
Runs ldapuserenum.py on any host which has 389/TCP open (in  the 
backend database).

A dictionary of file usernames is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_ldap_usernames
\$ yaptest-config.pl set dict_ldap_usernames /home/u/dicts/ldap-users.txt

NB: ldapuserenum.py is required to be in the path.
";

my $y = yaptest->new();
my $dictionary_file = $y->get_config('dict_ldap_usernames');

unless (defined($dictionary_file)) {
        print "ERROR: No dictionary has been configured for ldapuserenum.py.\n";
        die $usage;
}

die $usage if shift;

$y->run_test(
	command => "ldapuserenum.py -l $dictionary_file -t ::IP::",
	parallel_processes => $max_processes,
	filter => { port => 389, transport_protocol => 'TCP' },
	max_lines => 110,
	output_file => 'ldapuserenum-::IP::-::PORT::.out',
	inactivity_timeout => 300,
	parser => 'yaptest-parse-ldapuserenum.pl'
);
