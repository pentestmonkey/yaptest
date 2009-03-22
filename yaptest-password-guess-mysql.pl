#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses hydra to guess MySQL passwords on systems in the database with 3306/TCP open.

Dictinaries of usernames and passwords are required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_mysql_usernames
\$ yaptest-config.pl set dict_mysql_usernames /home/u/dicts/mysql-usernames.txt
\$ yaptest-config.pl query dict_mysql_passwords
\$ yaptest-config.pl set dict_mysql_passwords /home/u/dicts/mysql-passwords.txt

NB: hydra is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $username_file = $y->get_config('dict_mysql_usernames');
my $password_file = $y->get_config('dict_mysql_passwords');

unless (defined($password_file)) {
	print "ERROR: No password dictionary has been configured for hydra/mysql\n";
	die $usage;
}

unless (defined($username_file)) {
	print "ERROR: No username dictionary has been configured for hydra/mysql\n";
	die $usage;
}

$y->run_test(
	command => "hydra -L $username_file -P $password_file -e ns ::IP:: mysql",
	# command => "medusa -h ::IP:: -U $username_file -P $password_file -e ns -M mysql",
	filter => { port => 3306 },
	output_file => "password-guess-mysql-::IP::.out",
	parser => "yaptest-parse-hydra.pl"
);
