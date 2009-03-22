#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name ldapuserenum-10.0.0.1-389.out [ ldapuserenum-10.0.0.2-389.out ]

Parses ldapuserenum output and adds issues to databases.  IP and port must be in the filename.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless ($filename =~ /(\d+\.\d+\.\d+\.\d+)-(\d+)/) {
		print "WARNING: Filename $filename doesn't contain an IP address and port.  Skipping...\n";
		next;
	}
	my $ip = $1;
	my $port = $2;
	print "IP: $ip, PORT: $port\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	my %issue;
	my $is_ssl = 0;
	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;

		# [*] Enumerated users:
		#         [*] User: administrator
		#                 [*] LDAP error code: 52e
		#                 [*] LDAP message: invalid credentials
		if ( $line =~ / User: (\S.*)\s*$/) {
			my $user = $1;
			print "PARSED: Username: $user\n";
			$y->insert_credential(ip_address => $ip, username => $user, credential_type_name => "os_windows");
			$y->insert_issue(name => "ldap_user_enum", ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}
		
	}
}
$y->commit;
$y->destroy;
