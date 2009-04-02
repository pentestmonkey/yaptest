#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $port = 2049;
my $usage = "Usage: $script_name nfs-10.0.0.1.out [ nfs-10.0.0.2.out ]

Parses nfs output and adds issues to databases.
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

	my %issue;
	while (<FILE>) {
		# print;
		chomp;
		my $line = $_;

		# [+] Successfully mounted and listed /some/export on 1.2.3.4
		if ( $line =~ /Successfully mounted and listed (.*) on (\d+\.\d+\.\d+\.\d+)/) {
			my $export = $1;
			my $ip = $2;
			my $issue = "nfs_mountable";
			print "PARSED: IP: $ip, Export: $export, Issue: $issue\n";
			$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}

		# [+] File successfully uploaded to /some/export on 1.2.3.4.  SUID bit: s
		if ( $line =~ /File successfully uploaded to (.*) on (\d+\.\d+\.\d+\.\d+)/) {
			my $export = $1;
			my $ip = $2;
			my $issue = "nfs_writable";
			print "PARSED: IP: $ip, Export: $export, Issue: $issue\n";
			$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}

		# [+] File successfully create device node on /some/export on 1.2.3.4.
		if ( $line =~ /File successfully create device node on (.*) on (\d+\.\d+\.\d+\.\d+)/) {
			my $export = $1;
			my $ip = $2;
			my $issue = "nfs_mknod";
			print "PARSED: IP: $ip, Export: $export, Issue: $issue\n";
			$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => 'TCP');
		}
	}
}
$y->commit;
$y->destroy;
