#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Data::Dumper;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name traceroute.out [ traceroute.out.2 ... ]
Parses topology information from the output of 'traceroute -n ip' into the backend database.
";

my $have_arg = shift or die $usage;
unshift @ARGV, $have_arg;
my $verbose = 1;
my $y = yaptest->new;
my $commit = 1;

while (my $file = shift) {
	print "Processing $file...\n";

	# Check we can open file
	unless (open (FILE, "<$file")) {
		warn "WARNING: Can't open file $file for reading.  Ignoring.  Error was: $!\n";
		next;
	}

	my $prev_ip = undef;
	my @ip_list = ();
	my $ping_target = undef;
	while (<FILE>) {
		chomp;
		my $line = $_;
		print "$line\n" if $verbose;

		my ($hop, $ip) = $line =~ /^\s*(\d+)\s+(\d+\.\d+\.\d+\.\d+)\s+/;

		if (defined($ip)) {
			$y->insert_router_hop($ip, $hop);
			if (defined($prev_ip)) {
				print "PARSED: $prev_ip -> $ip\n";
				if (not $ip eq $prev_ip) {
					$y->insert_topology($prev_ip, $ip);
				}
			}
		
			$prev_ip = $ip;
		} else {
		        $prev_ip = undef;
		}

		$y->commit if $commit;
	}

	close(FILE);
}

