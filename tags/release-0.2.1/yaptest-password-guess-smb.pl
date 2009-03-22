#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;
use File::Temp "tempfile";

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses hydra to guess SMB passwords against systems in the database with 139 or 445/TCP open.

The username list for this script is compiled by reading in a file of common 
usernames (see below) and using all known usernames currently in the backend 
database.

WARNING: It is possible to lock accounts out using this script.

Dictinaries of usernames and passwords are required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_smb_usernames
\$ yaptest-config.pl set dict_smb_usernames /home/u/dicts/smb-usernames.txt
\$ yaptest-config.pl query dict_smb_passwords
\$ yaptest-config.pl set dict_smb_passwords /home/u/dicts/smb-passwords.txt

NB: hydra is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $aref = $y->get_credentials(credential_type_name => "os_windows", test_area_name => $ENV{'YAPTEST_TESTAREA'});
my %usernames;
my $username_file = $y->get_config('dict_smb_usernames');
my $password_file = $y->get_config('dict_smb_passwords');

unless (defined($password_file)) {
	print "ERROR: No password dictionary has been configured for hydra/smb\n";
	die $usage;
}

unless (defined($username_file)) {
	print "ERROR: No username dictionary has been configured for hydra/smb\n";
	die $usage;
}

# read in all windows usernames from database
foreach my $rowref (@$aref) {
	my $username = $rowref->{'username'};
	$usernames{$username} = 1;
}

# read in default list of windows usernames
open FILE, "<$username_file" or die "ERROR: Can't open $username_file\n";
my @usernames = <FILE>;
map { chomp $_; $usernames{$_} = 1 } @usernames;
undef @usernames;
close FILE;

# write combined lists to a file
my $out_fh;
($out_fh, $username_file) = tempfile('yaptest-windows-usernames-XXXXX');
foreach my $username (sort keys %usernames) {
	print $out_fh "$username\n";
}
close $out_fh;

$y->run_test(
	command => "hydra -L $username_file -P $password_file -e ns ::IP:: smb",
	filter => { port => [139, 445] },
	output_file => "password-guess-smb-::IP::.out",
	parser      => "yaptest-parse-hydra.pl"
);
