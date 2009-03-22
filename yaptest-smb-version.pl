#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses Metasploit 3 auxiliary/scanner/smb/version module on each IP 
to with 445 or 139/TCP open in backend database.

NB: msfcli from Metasploit 3 is required to be in the path.
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
	command => $ms3_dir . "msfcli auxiliary/scanner/smb/version RHOSTS=::IP:: E",
	filter => { port => [139, 445] },
	timeout => 30,
	output_file => "smb-version-::IP::.out",
	parallel_processes => 8 
);
