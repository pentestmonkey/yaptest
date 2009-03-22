#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Temp qw/ tempdir /;
use File::Basename;

my $ip;
my $port;
my $need_update = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name fpdns-10.0.0.1.out [ fpdns-10.0.0.2.out ... ]

Parses the output of fpdns.
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

	if ($file =~ /-(\d+\.\d+\.\d+\.\d+)/) {
		$o_host = $1;
	} else {
		print "ERROR: Can't determine IP and port from filename: $file.  Skipping\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;
	
		if ( $line =~ /^(\d+\.\d+\.\d+\.\d+).*\s\[recursion enabled\]/) {
			print "PARSED: $o_host allows recursive lookups\n";
		}

		$y->insert_issue(name => 'dns_rec_lookup', ip_address => $o_host, port => 53, transport_protocol => 'UDP');
	}

	$y->commit;

}
$y->destroy;
