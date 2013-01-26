#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;
use Data::Dumper;

my $script_name = basename($0);
my $usage = "Usage: $script_name enum4linux-10.0.0.1.out [ enum4linux-10.0.0.2.out ]

Parses enum4linux output for Windows usernames, OS information.  IP must be in the filename.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my %dc_for;
my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless ($filename =~ /(\d+\.\d+\.\d+\.\d+)/) {
		print "WARNING: Filename $filename doesn't contain an IP address.  Skipping...\n";
		next;
	}


	my $ip = $1;
	print "IP: $ip\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	my $state = "needuser";
	my $username;
	while (<FILE>) {
		print;
		chomp;
		chomp;
		my $line = $_;
		$line =~ s/\x0d//g;
		if ($state eq "needuser" and $line =~ /^(\S.*)$/) {
			$username = $1;
			$state = "gotuser";
			print "PARSED: Host $ip, user: $username $state\n";
		} elsif ($state eq "gotuser" and $line =~ /^\s*User ID:\s*(\d+)/) {
			my $uid = $1;
			print "PARSED: Host $ip, user: $username, uid: $uid\n";
			$y->insert_credential(ip_address => $ip, uid => $uid, username => $username, credential_type_name => "os_windows");
			$state = "needuser";
		}

		# Password policy
		if ($line =~ /Account Lockout Threshold: (\S+)/) {
			my $threshold = $1;
			print "PARSED: Host $ip has lockout threshold: $threshold\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_acct_lockout_threshold", value => $threshold);
		}
		if ($line =~ /Minimum password length: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Minimum password length: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_min_password_len", value => $value);
		}
		if ($line =~ /Password history length: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Password history length: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_password_hist_len", value => $value);
		}
		if ($line =~ /Maximum password age: ([\S ]+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Maximum password age: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_max_password_age", value => $value);
		}
		if ($line =~ /Password Complexity Flags: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has /Password Complexity Flags: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_password_complexity", value => $value);
		}
		if ($line =~ /Reset Account Lockout Counter: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has /Reset Account Lockout Counter: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_reset_acct_lockout_ctr", value => $value);
		}
		if ($line =~ /Locked Account Duration: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Locked Account Duration: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_acct_lockout_duration", value => $value);
		}
	}
}
$y->commit;
$y->destroy;

