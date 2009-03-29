#!/usr/bin/env perl
use warnings;
use strict;
use POSIX;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name udp-proto-scanner.out
Read udp-proto-scanner output and insert open ports into the database.

";

my $y = yaptest->new();
my $commit = 1;
my $file = shift or die $usage;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	my $xml; 
	
	if ($@) {
		print "WARNING: File $file is corrupt.  Skipping.\n";
		next;
	}
	
	unless (open (FILE, "<$file")) {
		warn "ERROR: Can't open $file for reading.  Skipping.\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;
		next unless ($line =~ /^Received reply to probe (\S+) \(target port (\d+)\) from (\d+\.\d+\.\d+\.\d+):(\d+):\s([0-9a-f]+)/);
		my $probe = $1;
		my $port = $2;
		my $ip = $3;
		my $reply_port = $4;
		my $reply = $5;
		print "PARSED: IP=$ip, PORT=$port, TRANS=UDP\n";
		$y->insert_port(ip => $ip, transport_protocol => "UDP", port => $port);
		$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'UDP', port_info_key => "ups_reply", port_info_value => $reply);
		$y->insert_issue(name => "mssql_ping",    ip_address => $ip, port => $port, transport_protocol => 'UDP') if ($probe eq "ms-sql"); 
		$y->insert_issue(name => "mssql_slammer", ip_address => $ip, port => $port, transport_protocol => 'UDP') if ($probe eq "ms-sql-slam"); 
	}
}	
$y->{dbh}->commit if $commit;

