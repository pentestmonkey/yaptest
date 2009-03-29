#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name hoppy-10.0.0.1-80.out [ hoppy-10.0.0.2-80.out ]

Parses hoppy output and adds issues to databases.  IP and port must be in the filename.
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

		if ( $line =~ /^\s+Put\s+-\s+HTTP\/1.[01]\s+201\s+Created/) {
			$issue{http_put_enabled} = 1;
			print "PARSED: http_put_enabled\n";
		}
	}

	foreach my $issue (keys %issue) {
		$y->insert_issue(name => $issue, ip_address => $ip, port => $port, transport_protocol => 'TCP');
	}
}
$y->commit;
$y->destroy;
