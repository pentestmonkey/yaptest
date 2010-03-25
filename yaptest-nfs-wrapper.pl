#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Data::Dumper;
use File::Basename;
use Expect;

my $script_name = basename($0);
my $usage = "Usage: $script_name ip exported-dir
Big, dirty wrapper around nfsshell.

It uses the PERL Expect module.  It's called 'Expect' in CPAN or
dev-perl/Expect as a gentoo package.

[ This script is a work in progress, but it kinda works and saves you ]
[ some effort if you've got a lot of NFS exports to explore.          ]

Mounts an NFS export directory from a given host and performs some checks:
- We can do a directory listing (confirms a successful mount)
- Tries to upload a file (checks for write access).  Alters UID automatically.
- Tries to mknod a device node.  Alters UID to 0 for this automatically.

Limitations: Messy output.
             Doesn't comprehensively detect error (but has been tested).
             Will clobber text.txt in the current dir!
             Dosn't save output.

NB: 'nfs' (nfsshell) is required to be in the path.  Run as root.
";

my $ip = shift or die $usage;
my $export = shift or die $usage;
die $usage if shift;

# Check we're root
unless (geteuid == 0) {
	print "WARNING: You should run this as root otherwise you might not be able to mount some NFS exports.\n";
	sleep 3;
	print "Continuing anyway...\n\n";
}

my $fail_pattern = "TODO";
my $prompt = "nfs>";
my $debug = 1;
my $timeout = 20;

my $command = "nfs";
print "[D] COMMAND: $command\n" if $debug;
my $exp = new Expect;
$exp->spawn($command) or die "Cannot spawn command: $command\n";
$exp->log_stdout(1);
$exp->exp_internal(0);
my $result = $exp->expect($timeout, $prompt);

if ($result == 1) {
	print "\n[D]STATE 0: Need to send ip\n";
	my $to_send = "host $ip\n";
	print "[D] Sending $to_send\n";
	$exp->send("$to_send"); 
	$result = $exp->expect($timeout, $prompt);
}
	
if ($result == 1) {
	print "\n[D]STATE 1: Need to mount export\n";
	my $to_send = "mount $export\n";
	print "[D] Sending $to_send\n";
	$exp->send("$to_send"); 
	$result = $exp->expect($timeout, $prompt, "Mount failed: Permission denied");
	
	if ($result == 2) {
		print "[E] Failed to mount export.  This can happen if export name is wrong too.\n";
		exit 1;
	}
}
	
my $uid = undef;
my $group_write;
my $world_write;
if ($result == 1) {
	print "\n[D] STATE 2: Need directory listing\n";
	my $to_send = "ls -l\n";
	$exp->send("$to_send"); 
	$result = $exp->expect($timeout, $prompt, $fail_pattern, '-re', qr/d....(.)..(.).\s*(\d+)\s*\d+\s*\d+\s*\d+\s*.*\s+\.\s*$/);
	
	if ($result == 3) {
		$group_write = ($exp->matchlist)[0];
		$world_write = ($exp->matchlist)[1];
		$uid = ($exp->matchlist)[2];
		print "\n[+] Successfully mounted and listed $export on $ip\n";
		print "[D] Parsed the directory listing $uid\n";
		print "\n[D] STATE 2.5: Need rest of directory listing\n";
		$result = $exp->expect($timeout, $prompt);
	}
}

system ("echo test > test.txt"); # TODO this is dirty
if (defined($uid)) {
	print "\n[D] STATE 2.6: Need to change UID\n";
	my $to_send = "uid $uid\n";
	$exp->send("$to_send"); 
	$result = $exp->expect($timeout, $prompt);
	
	if ($result == 1) {
		print "\n[D] STATE 2.7: Need to upload a file\n";
		my $to_send = "put test.txt .test-file-please-delete\n";
		$exp->send("$to_send"); 
		$result = $exp->expect($timeout, $prompt, "Read-only file system");
		if ($result == 2) {
			print "[+] File upload failed for $export on $ip.  Read only filesystem\n";
			print "\n[D] STATE 2.995: Need prompt\n";
			$result = $exp->expect($timeout, $prompt, $fail_pattern);
		} elsif ($result == 1) {
			my $to_send = "chmod 4755 .test-file-please-delete\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt);
			$to_send = "uid 0\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt, $fail_pattern);
			$to_send = "mknod .test-nod-please-delete b 85 0\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt);
			$to_send = "uid $uid\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt, $fail_pattern);
			print "\n[D] STATE 2.8: Need another directory listing\n";
			$to_send = "ls -l .test-file-please-delete\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt, $fail_pattern, '-re', qr/-..(.)......\s*\d+\s*[\d-]+\s+\d+\s+\d+\s+[a-zA-Z0-9 ]+\.test-file-please-delete/);
			if ($result == 3) {
				my $suid = ($exp->matchlist)[0];
				print "[+] File successfully uploaded to $export on $ip.  SUID bit: $suid\n";
				print "\n[D] STATE 2.95: Need rest of directory listing\n";
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
				$to_send = "rm .test-file-please-delete\n";
				$exp->send("$to_send"); 
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
			}
			print "\n[D] STATE 2.98: Need another directory listing\n";
			$to_send = "ls -l .test-nod-please-delete\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt, $fail_pattern, '-re', qr/b.........\s*\d+\s*[\d-]+\s+\d+\s+\d+\s+[a-zA-Z0-9 ]+\.test-nod-please-delete/);
			if ($result == 3) {
				print "[+] File successfully create device node on $export on $ip.\n";
				print "\n[D] STATE 2.9995: Need rest of directory listing\n";
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
				$to_send = "uid 0\n";
				$exp->send("$to_send"); 
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
				$to_send = "rm .test-nod-please-delete\n";
				$exp->send("$to_send"); 
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
				my $to_send = "uid $uid\n";
				$exp->send("$to_send"); 
				$result = $exp->expect($timeout, $prompt, $fail_pattern);
			}
			print "\n[D] STATE 2.9: Need yet another directory listing\n";
			$to_send = "ls -l\n";
			$exp->send("$to_send"); 
			$result = $exp->expect($timeout, $prompt, $fail_pattern);
		}
	}
	if ($result == 2) {
		print "[E] Failed to get directory listing\n";
		exit 1;
	}
}

if ($result == 1) {
	print "\n[D] STATE 3: Need to exit\n[D]\n";
	my $to_send = "quit\n";
	$exp->send("$to_send"); 
	$result = $exp->expect($timeout, $prompt, $fail_pattern);
}


