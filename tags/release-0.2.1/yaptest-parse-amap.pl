#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name amap.out [amap.out.2 ... ]
Parse the output from amap an enter it into the database.
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
		yaptest::parse::amap($line);
	}

	close(FILE);
}

package yaptest::parse;

use yaptest;

sub amap {
	my $line = shift;
	my $commit = 1;

	my $connection = yaptest->new;

	# Protocol on 10.0.0.1:443/tcp matches ssl
	if ($line =~ /^Protocol on ((?:\d{1,3}\.){3}\d{1,3}):(\d{1,5})\/tcp matches ssl/) {
		my $ip = $1;
		my $port = $2;
		print "PARSED: SSL on IP=$ip, PORT=$port\n";
		$connection->insert_port(ip => $ip, transport_protocol => "tcp", port => $port);
                $connection->insert_port_info(
                          ip                 => $ip,
                          port               => $port,
                          transport_protocol => "TCP",
                          port_info_key      => "amap_service_tunnel",   
                          port_info_value    => "ssl"
                );
		$connection->commit if $commit;
	}
}
