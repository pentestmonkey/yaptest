#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses hydra to guess MSSQL passwords on systems in the database with 1433/TCP open.

Dictinaries of usernames and passwords are required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_mssql_usernames
\$ yaptest-config.pl set dict_mssql_usernames /home/u/dicts/mssql-usernames.txt
\$ yaptest-config.pl query dict_mssql_passwords
\$ yaptest-config.pl set dict_mssql_passwords /home/u/dicts/mssql-passwords.txt

NB: hydra is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $username_file = $y->get_config('dict_mssql_usernames');
my $password_file = $y->get_config('dict_mssql_passwords');

unless (defined($password_file)) {
	print "ERROR: No password dictionary has been configured for hydra/mssql\n";
	die $usage;
}

unless (defined($username_file)) {
	print "ERROR: No username dictionary has been configured for hydra/mssql\n";
	die $usage;
}

$y->run_test(
	# command => "hydra -L $username_file -P $password_file -e ns ::IP:: mssql",
	command => "medusa -h ::IP:: -U $username_file -P $password_file -e ns -M mssql",
	filter => { port => 1433 },
	output_file => "password-guess-mssql-::IP::.out",
	parser => "yaptest-parse-medusa.pl"
);
