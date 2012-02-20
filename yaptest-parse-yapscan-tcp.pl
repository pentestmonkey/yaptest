#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name yapscan.out [yapscan.out.2 ... ]
Parse the output from yapscan an enter it into the database.
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
		yaptest::parse::yapscan($line);
	}

	close(FILE);
}

package yaptest::parse;

use yaptest;

sub yapscan {
	my $line = shift;
	my $commit = 1;

	my $connection = yaptest->new;

	if ($line =~ /^((?:\d{1,3}\.){3}\d{1,3}):(\d{1,5})\s+\S+\s+Len=\d+\s+TTL=(\d+) IPID=(\d+)/) {
		my $ip = $1;
		my $port = $2;
		my $ttl = $3;
		my $ipid = $4;
		if ($line =~ /AR/) {
			print "PARSED: (closed) IP=$ip, PORT=$port, DESC=$ttl, IPID=$ipid\n";
			$connection->insert_ip($ip);
		} elsif ($line =~ /FLAGS=S/) {
			print "PARSED: (open) IP=$ip, PORT=$port, DESC=$ttl, IPID=$ipid\n";
			$connection->insert_port(ip => $ip, transport_protocol => "tcp", port => $port);
		} else {
			print "PARSED: (open) IP=$ip, PORT=$port, DESC=$ttl, IPID=$ipid - WARNING unrecognised flags.  Ignoring\n";
		}
		$connection->insert_router_icmp_ttl($ip, $ttl); # todo this uses icmp_ttl, but it's a tcp ttl
		$connection->commit if $commit;
	}
}
