#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses Metasploit 3 auxiliary/scanner/oracle/sid_brute to guess default sids
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
	command => $ms3_dir."msfcli auxiliary/scanner/oracle/sid_enum RHOSTS=::IP:: RPORT=::PORT:: E",
	filter => { port_info => "nmap_service_name = oracle-tns" },
	timeout => 60,
	output_file => "oracle-sids-enum-::IP::-::PORT::.out",
	parallel_processes => 6,
	parser => ""
);

$y->run_test(
	command => $ms3_dir."msfcli auxiliary/scanner/oracle/sid_brute RHOSTS=::IP:: RPORT=::PORT:: VERBOSE=false E",
	filter => { port_info => "nmap_service_name = oracle-tns" },
	timeout => 60,
	output_file => "oracle-sids-guess-::IP::-::PORT::.out",
	parallel_processes => 6,
	parser => ""
);