#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name smtp-user-enum.out [ smtp-user-enum.out.2 ]

Parses smtp-user-enum.pl output for usernames.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;

		# 10.0.0.1: bin exists
		if ($line =~ /^(\d+\.\d+\.\d+\.\d+): (.*) exists\s*$/) {
			my $ip = $1;
			my $username = $2;
			print "PARSED: IP=$ip USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
		
		}
	}
}
$y->commit;
$y->destroy;
