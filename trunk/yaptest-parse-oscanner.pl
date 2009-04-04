#!/usr/bin/env perl
use warnings;
use strict;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Temp qw/ tempdir /;
use File::Basename;

my $ip;
my $port;
my $need_update = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name oscanner-10.0.0.1-1521.out [ oscanner-10.0.0.2-1521.out ... ]

Adds username, passwords, sids found by oscanner to backend database.
";

GetOptions (
);

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

my ($o_host, $o_port, $o_sid, $o_user, $o_pass);
while ($file = shift) {
	unless (open (FILE, "<$file")) {
		print "ERROR: Can't open file $file for reading: $!.  Skipping.\n";
		next;
	}

	if ($file =~ /(\d+\.\d+\.\d+\.\d+)-(\d+)/) {
		$o_host = $1;
		$o_port = $2;
	} else {
		print "ERROR: Can't determine IP and port from filename: $file.  Skipping\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;
	
		if ( $line =~ /Checking host (\d+\.\d+\.\d+\.\d+)/) {
			$o_host = $1;
			print "PARSED: Oracle host: $o_host\n";
		}

		if ( $line =~ /Checking sid \((.*)\) for common passwords/) {
			$o_sid = $1;
			print "PARSED: Oracle host: $o_host, Oracle SID: $o_sid\n";
		}

		if ( $line =~ /Account (.*)\/(.*) found/) {
			$o_user = $1;
			$o_pass = $2;
			print "PARSED: Oracle host: $o_host, Oracle SID: $o_sid, user=$o_user, pass=$o_pass\n";
			$y->insert_credential(ip_address => $o_host, port => $o_port, transport_protocol => "TCP", domain => $o_sid, username => $o_user, password => $o_pass, credential_type_name => "oracle");
		}
	}

	$y->commit;

}
$y->destroy;
