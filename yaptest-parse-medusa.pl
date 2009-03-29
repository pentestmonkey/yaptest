#!/usr/bin/perl -w
use strict;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name medusa.out [ medusa2.out ]

Parses usernames and password found by medusa into the database.

Limitations:
  - If multiple passwords are found for a single user
    then only the last one is recorded in the database.
    This often happends for anonymous ftp for example.
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
		print;
		chomp;
		my $line = $_;

		# ACCOUNT FOUND: [mssql] Host: 10.0.0.1 User: sa Password: password [SUCCESS]
		if ($line =~ /ACCOUNT FOUND: \[(mysql|mssql|smbnt)\] Host: (\d+\.\d+\.\d+\.\d+) User: (.*) Password: (.*) \[SUCCESS\]/) {
			my $type= $1;
			if ($type eq "smbnt") {
				$type = "os_windows";
			}
			my $ip = $2;
			my $username = $3;
			my $password = $4;
			print "PARSED: IP=$ip, TYPE=$type, USER=$username, PASSWORD=$password\n";

			$y->insert_credential(ip_address => $ip, username => $username, password => $password, credential_type_name => $type);
		}
	}
}
$y->commit;
$y->destroy;
