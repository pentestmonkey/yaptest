#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Data::Dumper;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name ping-r.out [ ping-r.out.2 ... ]
Parses topology information output from 'ping -R ip' into the backend database.
";

my $have_arg = shift or die $usage;
unshift @ARGV, $have_arg;
my $verbose = 1;
my $y = yaptest->new;
my $commit = 1;

while (my $file = shift) {
	print "Processing $file...\n";

	#
	# First parse the TTLs.  We'll need these during the second parse.
	#
	
	# Check we can open file
	unless (open (FILE, "<$file")) {
		warn "WARNING: Can't open file $file for reading.  Ignoring.  Error was: $!\n";
		next;
	}

	while (<FILE>) {
		chomp;
		my $line = $_;
		print "$line\n" if $verbose;
		if ($line =~ /\d+ bytes from (\d+\.\d+\.\d+\.\d+): icmp_seq=\d+ ttl=(\d+) time=\d/) {
			my $ip = $1;
			my $ttl = $2;
			print "PARSED: IP=$ip, TTL=$ttl\n";
			$y->insert_router_icmp_ttl($ip, $ttl);
		}
	}

	close FILE;

	#
	# Second, parse the topology info.
	#
	
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

		if ($line =~ /PING.*\((\d+\.\d+\.\d+\.\d+)\).*bytes of data./) {
			$ping_target = $1;
		}

		my $new;
		$new = 1 if ($line =~ /^RR:/);
		my ($ip) = $line =~ /^(?:RR:)?\s+(\d+\.\d+\.\d+\.\d+)/;

		if (defined($new)) {
			@ip_list = ();
		}

		if (defined($ip)) {
			push @ip_list, $ip;
			if (defined($prev_ip)) {
				print "PARSED: $prev_ip -> $ip\n";
				if (not $ip eq $prev_ip) {
					$y->insert_topology($prev_ip, $ip);
				}
			}
		
			$prev_ip = $ip;
		} else {
		        $prev_ip = undef;
			if (@ip_list) {
				# process the list of hops
				print "PARSED: Ping target: $ping_target\n";
				my @delete_indices;
				foreach my $index (0..scalar(@ip_list) - 1) {
					if ($ip_list[$index] eq $ping_target) {
						push @delete_indices, $index;
					}
				}
				while (scalar(@delete_indices) > 1) {
					my $index = pop @delete_indices;
					splice @ip_list, $index, 1;
				}
				my $middle_idx = $delete_indices[0];

				if (defined($middle_idx)) {
					my $hop  = 1;
					for my $i (0..$middle_idx) {
						printf "Hop %d: %s\n", $i, $ip_list[$i];
						$y->insert_router_hop($ip_list[$i], $i);
					}
					my $inc = 0;
					if ($middle_idx != scalar(@ip_list) - 1) {
						for my $i ($middle_idx+1..scalar(@ip_list)-1) {
							printf "Hop %d: %s\n", $middle_idx - $inc - 1, $ip_list[$i];
							$y->insert_router_hop($ip_list[$i], $middle_idx - $inc - 1);
							$inc++;
						}
					}
				} else {
					# if ping_target doesn't appear in output of ping -R
					# we'll only take hop numbers from the first N/2 ips
					my $hop  = 1;
					for my $i (0..int(scalar(@ip_list)/2)) {
						printf "Hop %d: %s\n", $i, $ip_list[$i];
						$y->insert_router_hop($ip_list[$i], $i);
					}
				}

				my $offset = 1;
				while (defined($middle_idx) and $middle_idx - $offset >= 0 and $middle_idx + $offset < scalar(@ip_list)) {
					printf "PARSED: %s == %s\n", $ip_list[$middle_idx - $offset], $ip_list[$middle_idx + $offset];
					#
					# PROBLEM:
					# This technique doesn't work when we're pinging the far interface of a router
					#   router1-far
					#   router2-far
					#   router2-near
					#
					# This doesn't happen very often, but it does happen and we can't tell when it has.
					# We therefore only conculde two IPs are on the same box if their TTLs are the
					# same.  If the TTLs are missing then out technique is foiled!
					#
					my $ttl1 = $y->get_router_icmp_ttl($ip_list[$middle_idx - $offset]);
					my $ttl2 = $y->get_router_icmp_ttl($ip_list[$middle_idx + $offset]);
					if (defined($ttl1) and defined($ttl2) and $ttl1 == $ttl2) {
						$y->associate_interfaces($ip_list[$middle_idx - $offset], $ip_list[$middle_idx + $offset]);
					}
					$offset++;
				}
				@ip_list = ();
				$ping_target = undef;
			}
		}
		$y->commit if $commit;
	}

	close(FILE);
}

