#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use Data::Dumper;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name snmpwalk-10.0.0.1.out [ snmpwalk-10.0.0.2.out ]

Parses snmpwalk output for Windows usernames.  IP must be in the filename.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

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

	my @interface_ips = ();
	while (<FILE>) {
		print;
		chomp;
		my $line = $_;

		# Windows systems list all users...
		# enterprises.77.1.2.25.1.1.5.71.117.101.115.116 = STRING: "Guest"
		if ($line =~ /^enterprises\.77\.1\.2\.25\.1\.1.* = STRING: "(.*)"\s*$/) {
			my $username = $1;
			print "PARSED: USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_windows");
		
		# Unix systems list some users in the process listing...
		# enterprises.42.3.12.1.1.8.216 = STRING: "root"
		} elsif ($line =~ /^enterprises.42.3.12.1.1.8.\d+\s*=\s*STRING: "(.*)"\s*$/) {
			my $username = $1;
			print "PARSED: USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
		} elsif ($line =~ /ipAdEntAddr\.(\d+\.\d+\.\d+\.\d+) = IpAddress: (\d+\.\d+\.\d+\.\d+)/) {
			my $ip1 = $1;
			my $ip2 = $2;
			if ($ip1 eq $ip2 and not ($ip1 eq "127.0.0.1" or $ip1 eq "0.0.0.0")) {
				push @interface_ips, $ip1;
			}
		}

		# ipAdEntNetMask.10.0.0.1 = IpAddress: 255.255.255.0
		if ($line =~ /ipAdEntNetMask\.$ip = IpAddress: (\d+\.\d+\.\d+\.\d+)/) {
			my $netmask = $1;
			print "PARSED: IP=$ip Netmask=$netmask\n";
			$y->insert_netmask($ip, $netmask);
		}
	}

	my $first_ip = shift(@interface_ips);
	foreach my $ifaceip (@interface_ips) {
		print "PARSED: $first_ip is on the same box as $ifaceip\n";
		$y->associate_interfaces($first_ip, $ifaceip);
	}
}
$y->commit;
$y->destroy;
