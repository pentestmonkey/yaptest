#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

# Tool to parse the output from arp-scan and enter it in the database.

my $script_name = basename($0);
my $usage = "Usage: $script_name arp-scan.out [arp-scan.out.2 ... ]

Parse the output from arp-scan an enter it into the database.
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
		if ($line =~ /^\s*((?:\d{1,3}\.){3}\d{1,3})\s+((?:[a-fA-F0-9]{2}:){5}[a-fA-F0-9]{2})\s+(\S.*)/) {
			my $ip = $1;
			my $mac = $2;
			my $desc = $3;
			print "PARSED: IP=$ip, MAC=$mac, DESC=$desc\n";
			$y->insert_ip_and_mac($ip, $mac);
			$y->insert_host_info(ip_address => $ip, key => "mac_vendor", value => $desc);
		}
	}

	close(FILE);
}

$y->{dbh}->commit;
