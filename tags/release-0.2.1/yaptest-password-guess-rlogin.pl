#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses hydra to guess rlogin passwords on systems in the database with 513/TCP open.

Dictinaries of usernames and passwords are required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_rlogin_usernames
\$ yaptest-config.pl set dict_rlogin_usernames /home/u/dicts/rlogin-usernames.txt
\$ yaptest-config.pl query dict_rlogin_passwords
\$ yaptest-config.pl set dict_rlogin_passwords /home/u/dicts/rlogin-passwords.txt

NB: hydra is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $username_file = $y->get_config('dict_rlogin_usernames');
my $password_file = $y->get_config('dict_rlogin_passwords');

unless (defined($password_file)) {
	print "ERROR: No password dictionary has been configured for hydra/rlogin\n";
	die $usage;
}

unless (defined($username_file)) {
	print "ERROR: No username dictionary has been configured for hydra/rlogin\n";
	die $usage;
}

$y->run_test(
	command => "hydra -L $username_file -P $password_file -e ns ::IP:: rlogin",
	filter => { port => 513 },
	output_file => "password-guess-rlogin-::IP::.out",
	parser      => "yaptest-parse-hydra.pl"
);
