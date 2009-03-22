#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use Data::Dumper;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name finger-user-enum.out [ finger-user-enum.out.2 ]

Parses finger-user-enum.pl output for usernames.
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
		chomp;
		my $line = $_;

		# This format is for a Linux system.  Other finger daemons will differ,
		# so won't by parsed by this script.
		#
		# bin@10.0.0.1: Login: bin                                   Name: bin
		if ($line =~ /^(\S+)@(\d+\.\d+\.\d+\.\d+):\s*Login:\s*(\S+)\s+Name:/) {
			my $query = $1;
			my $ip = $2;
			my $username = $3;
			# NB: $query and $username aren't necessarily the same, e.g.:
			# admin@10.0.0.1: Login: bob                                   Name: FTP Admin user
			print "PARSED: IP=$ip USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
		
		}

		# This format is for a Solaris 10 system.
		#
		# adm@10.0.0.1: adm      Admin         
		# admin@10.0.0.1: Login       Name               TTY         Idle    When    Where..adm      Admin                              < .  .  .  . >..lp       Line Printer Admin                 < .  .  .  . >..uucp     uucp Admin                         < .  .  .  . >..nuucp    uucp Admin                         < .  .  .  . >..listen   Network Admin                      < .  
		if ($line =~ /^(\S+)@(\d+\.\d+\.\d+\.\d+):\s*\1\s*(\S+)\s+/) {
			my $query = $1;
			my $ip = $2;
			my $username = $1;
			print "PARSED: IP=$ip USER=$username\n";

			$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
		
		} elsif ($line =~ /^(\S+)@(\d+\.\d+\.\d+\.\d+):\s*Login\s+Name\s+TTY\s+Idle\s+When\s+Where\.\.(.*)/) {
			my $query = $1;
			my $ip = $2;
			my $rows = $3;
			my @rows = split /\.\./, $rows;
			foreach my $row (@rows) {
				if ($row =~ /^(\S+)\s+/) {
					my $username = $1;
					print "PARSED: IP=$ip USER=$username\n";
					$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");
				}
			}
		}
	}
}
$y->commit;
$y->destroy;
