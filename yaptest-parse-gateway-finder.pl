#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name gateway_finder.out [ gateway_finder.out.2 ... ]
Parse the output from gateway-finder.py and enters it into the database.
";

my $have_arg = shift or die $usage;
unshift @ARGV, $have_arg;
my $verbose = 1;

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
		yaptest::parse::gateway_finder($line);
	}

	close(FILE);
}

package yaptest::parse;

use yaptest;

sub gateway_finder {
	my $line = shift;
	my $commit = 1;

	my $connection = yaptest->new;

	# 11:22:33:44:55:66 [UnknownIP] appears to route ICMP Ping packets to 1.2.3.4.  Received ICMP TTL Exceeded in transit response.
	if ($line =~ /([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}).*(ICMP Ping|TCP).*ICMP TTL Exceeded/) {
		my $mac   = $1;
		my $probe = $2;

		if ($probe =~ /tcp/i) {
			$probe = "tcp";
		} elsif ($probe =~ /icmp/i) {
			$probe = "icmp";
		}

		my $ip = $connection->get_ip_from_mac(lc $mac);
		if ($ip) {
			print "PARSED: MAC=$mac, PROBE=$probe, IP=$ip\n";
			$connection->insert_issue(name => "ip_forwarding_enabled", ip_address => $ip);
			$connection->insert_host_info(ip_address => $ip, key => "ip_forwarding", value => $line);
			$connection->commit if $commit;
		} else {
			print "ERROR - can't find IP in database for MAC. PARSED: MAC=$mac, PROBE=$probe.  Skipping.\n";
		}
	}
}
