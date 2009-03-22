#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name ident-user-enum.out [ ident-user-enum.out.1 ]

Parses usernames from the output of ident-user-enum.pl.
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

		# 127.0.0.1:111       root
		# 127.0.0.1:1234      <unknown>
		if ($line =~ /^(\d+\.\d+\.\d+\.\d+):(\d+)\s+(.*?)\s*$/) {
			my $ip = $1;
			my $port = $2;
			my $username = $3;
			next if $username eq "<unknown>";
			print "PARSED: IP=$ip PORT=$port USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
		
		}
	}
}
$y->commit;
$y->destroy;
