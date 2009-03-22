#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name hydra.out [ hydra2.out ]

Parses usernames and password found by hydra into the database.

Limitations:
  - It's hard to parse passwords ending whitespace
    from hydra.  This may not work.
  - If multiple passwords are found from a sigle user
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

		# [22][ssh2] host: 10.0.0.1   login: root   password: root
		if ($line =~ /^\[(\d+)\]\[(www|ssh2|mysql|rlogin|ftp|smb)\]\s+host:\s+(\S+)\s+login:\s+(.*?)\s+password:\s+(\S*)\s*?$/) {
			my $port = $1;
			my $type= $2;
			$type = "http" if ($type eq "www");
			my $ip = $3;
			my $username = $4;
			my $password = $5;
			print "PARSED: IP=$ip, PORT=$port, TYPE=$type, USER=$username, PASSWORD=$password\n";

			$y->insert_credential(ip_address => $ip, port => $port, transport_protocol => "TCP", username => $username, password => $password, credential_type_name => $type);
		}
	}
}
$y->commit;
$y->destroy;
