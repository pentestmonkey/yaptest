#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name ssh-keyscan-1.2.3.4-22.out [ ssh-keyscan-1.2.3.5.-22out ... ]
Read output of ssh-keyscan and enters data into database.  The filename should
contain the IP address and port.
";

die $usage if $help;
my $file = shift or die $usage;
my $y = yaptest->new();
my $commit = 1;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	my ($current_ip, $port) = $file =~ /(\d+\.\d+\.\d+\.\d+)-(\d+)/;
	unless (open (FILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	undef $/;
	my $ssh_keyscan = <FILE>;
	$y->insert_port(ip => $current_ip, transport_protocol => "tcp", port => $port);
	$y->insert_port_info(
		ip                 => $current_ip,
		port               => $port,
		transport_protocol => "tcp",
		port_info_key      => "ssh_keyscan_tcp",
		port_info_value    => $ssh_keyscan
	);
}
$y->{dbh}->commit if $commit;
