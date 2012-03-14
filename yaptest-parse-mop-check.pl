#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name mop_check.out [ mop_check.out.2 ... ]
Parse the output from mop-check.py and enters it into the database.
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
		yaptest::parse::mop_check($line);
	}

	close(FILE);
}

package yaptest::parse;

use yaptest;

sub mop_check {
	my $line = shift;
	my $commit = 1;

	my $connection = yaptest->new;

	# [+] Recieved Reply From 11:22:33:44:55:66
	if ($line =~ /Recieved Reply From ([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2})/) {
		my $mac   = $1;

		my $ip = $connection->get_ip_from_mac(lc $mac);
		if ($ip) {
			print "PARSED: MAC=$mac, IP=$ip\n";
			$connection->insert_issue(name => "dec_mop_remote_console", ip_address => $ip);
			$connection->insert_host_info(ip_address => $ip, key => "dec_mop_remote_console", value => 1);
			$connection->commit if $commit;
		} else {
			print "ERROR - can't find IP in database for MAC. PARSED: MAC=$mac.  Skipping.\n";
		}
	}
}
