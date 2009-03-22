#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name yapscan.out [yapscan.out.2 ... ]
Parse the output from yapscan an enter it into the database.
";

my $have_arg = shift or die $usage;
unshift @ARGV, $have_arg;
my $y = yaptest->new; # connect to db
my $verbose = 1;
my $commit = 1;

while (my $file = shift) {
	print "Processing $file...\n";

	# Check we can open file
	unless (open (FILE, "<$file")) {
		warn "WARNING: Can't open file $file for reading.  Ignoring.  Error was: $!\n";
		next;
	}

	while (<FILE>) {
		chomp;
		my $line = $_;
		print "$line\n" if $verbose;
	        if ($line =~ /^((?:\d{1,3}\.){3}\d{1,3}):(\d{1,2})\/(\d{1,2})\s+\S+\s+Len=\d+\s+TTL=(\d+)/) {
	                my $ip = $1;
	                my $type = $2;
	                my $code = $3;
	                my $ttl = $4;
	                print "PARSED: IP=$ip, Type=$type, Code=$code\n";
	                $y->insert_icmp(ip => $ip, type => $type, code => $code);
			$y->insert_router_icmp_ttl($ip, $ttl);
			if ($type eq '0') {
		                $y->insert_issue(name => "icmp_echo", ip_address => $ip);
			} elsif ($type eq '14') {
		                $y->insert_issue(name => "icmp_timestamp", ip_address => $ip);
			} elsif ($type eq '18') {
		                $y->insert_issue(name => "icmp_addressmask", ip_address => $ip);
			} elsif ($type eq '16') {
		                $y->insert_issue(name => "icmp_info", ip_address => $ip);
			}
        	}
		# 10.0.0.1:18/0 [ADDRESS_REPLY] Len=32 TTL=255 IPID=61868 ID=26236 SEQ=46452 MASK=255.255.255.0
	        if ($line =~ /^((?:\d{1,3}\.){3}\d{1,3}):\d+\/\d+\s+\S+\s+Len=\d+\s+TTL=\d+.*MASK=((?:\d{1,3}\.){3}\d{1,3})/) {
			my $ip = $1;
			my $netmask = $2;
			print "PARSED: IP=$ip, Netmask=$netmask\n";
			$y->insert_host_info(ip_address => $ip, key => "icmp_netmask", value => $netmask);
			$y->insert_netmask($ip, $netmask);
		}
	}

	close(FILE);
}

$y->{dbh}->commit if $commit;
