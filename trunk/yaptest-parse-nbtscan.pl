#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name nbtscan.out [ nbtscan.out.2 ]

Parses nbtscan output for Windows hostnames.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	my $ip;
	print "Processing $filename ...\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;

		# NetBIOS Name Table for Host 10.0.0.1:
		if ($line =~ /NetBIOS Name Table for Host (\d+\.\d+\.\d+\.\d+):/) {
			$ip = $1;
		}
		if ($line =~ /^(\d+\.\d+\.\d+\.\d+).*SHARING/) {
			$ip = $1;
		}

		# HOSTNAME          <00>             UNIQUE
		if ($line =~ /^\s*([a-zA-Z0-9_-]+)[\s\x08]+<00>\s+UNIQUE/) {
			my $hostname = $1;
			print "PARSED: IP=$ip, HOST=$hostname\n";

			$y->insert_port(ip => $ip, port => 137, transport_protocol => 'UDP');
			$y->insert_hostname(type => 'windows_hostname', ip_address => $ip, hostname => $hostname);
			$y->insert_issue(name => 'nbt_info', ip_address => $ip, port => 137, transport_protocol => 'UDP');
		}

		# MYDOMAIN          <00>              GROUP
		if ($line =~ /^\s*([a-zA-Z0-9 _-]+?)[\s\x08]+<00>\s+GROUP/) {
			my $domain = $1;
			print "PARSED: IP=$ip, DOMAIN=$domain\n";

			$y->insert_host_info(ip_address => $ip, key => "windows_domwkg", value => $domain);
		}

		# MYDOMAIN          <1c>              GROUP
		if ($line =~ /^([a-zA-Z0-9_-]+)[\s\x08]+<1[cC]>\s+GROUP/) {
			my $domain = $1;
			print "PARSED: IP=$ip, DOMAIN=$domain\n";

			$y->insert_host_info(ip_address => $ip, key => "windows_dc", value => $domain);
			$y->insert_host_info(ip_address => $ip, key => "windows_member_of", value => "DOMAIN");
		}
	}
}
$y->commit;
$y->destroy;
