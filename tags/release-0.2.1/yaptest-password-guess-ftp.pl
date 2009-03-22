#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses hydra to guess FTP passwords on systems in the database with 21/TCP open.

Dictinaries of usernames and passwords are required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_ftp_usernames
\$ yaptest-config.pl set dict_ftp_usernames /home/u/dicts/ftp-usernames.txt
\$ yaptest-config.pl query dict_ftp_passwords
\$ yaptest-config.pl set dict_ftp_passwords /home/u/dicts/ftp-passwords.txt

NB: hydra is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $username_file = $y->get_config('dict_ftp_usernames');
my $password_file = $y->get_config('dict_ftp_passwords');

unless (defined($password_file)) {
	print "ERROR: No password dictionary has been configured for hydra/ftp\n";
	die $usage;
}

unless (defined($username_file)) {
	print "ERROR: No username dictionary has been configured for hydra/ftp\n";
	die $usage;
}

$y->run_test(
	command => "hydra -L $username_file -P $password_file -e ns ::IP:: ftp",
	filter => { port => 21 },
	output_file => "password-guess-ftp-::IP::.out",
	parser      => "yaptest-parse-hydra.pl"
);
