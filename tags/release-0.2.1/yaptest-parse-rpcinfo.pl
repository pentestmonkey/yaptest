#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name rpcinfo-1.2.3.4.out [ rpcinfo-1.2.3.5.out ... ]
Read output of rpcinfo and enters data into database.  The filename should
contain the IP address.
";

die $usage if $help;
my $file = shift or die $usage;
my $y = yaptest->new();
my $commit = 1;
my $awaiting_rpcinfo_start = 1;
my $awaiting_ip = 2;
my $awaiting_rpc_body = 3;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	my ($current_ip) = $file =~ /(\d+\.\d+\.\d+\.\d+)/;
	unless (open (RPCFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	undef $/;
	my $rpcinfo = <RPCFILE>;
	$y->insert_port(ip => $current_ip, transport_protocol => "tcp", port => 111);
	$y->insert_port_info(
		ip                 => $current_ip,
		port               => 111,
		transport_protocol => "tcp",
		port_info_key      => "rpcinfo_tcp",
		port_info_value    => $rpcinfo
	);

	# rexd
	if ($rpcinfo =~ / 100017 /) {
		$y->insert_issue(name => 'rpc_rexd', ip_address => $current_ip, port => 111, transport_protocol => "TCP");
	}
	# rusersd
	if ($rpcinfo =~ / 100002 /) {
		$y->insert_issue(name => 'rpc_rusersd', ip_address => $current_ip, port => 111, transport_protocol => "TCP");
	}
	# sprayd 
	if ($rpcinfo =~ / 100012 /) {
		$y->insert_issue(name => 'rpc_sprayd', ip_address => $current_ip, port => 111, transport_protocol => "TCP");
	}
	# statd 
	if ($rpcinfo =~ / 100001 /) {
		$y->insert_issue(name => 'rpc_rstatd', ip_address => $current_ip, port => 111, transport_protocol => "TCP");
	}
}
$y->{dbh}->commit if $commit;
