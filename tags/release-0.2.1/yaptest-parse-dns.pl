#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Temp qw/ tempdir /;
use File::Basename;

my $port;
my $need_update = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name dns-10.0.0.1.out [ dns-10.0.0.2.out ... ]

Parses the output of the misc DNS tests (yaptest-dns.pl).
";

GetOptions (
);

my $file = shift or die $usage;
unshift @ARGV, $file;

my $y = yaptest->new();

my ($ip, $o_port, $o_sid, $o_user, $o_pass);
while ($file = shift) {
	unless (open (FILE, "<$file")) {
		print "ERROR: Can't open file $file for reading: $!.  Skipping.\n";
		next;
	}

	if ($file =~ /-(\d+\.\d+\.\d+\.\d+)/) {
		$ip = $1;
	} else {
		print "ERROR: Can't determine IP and port from filename: $file.  Skipping\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;
	
		if ( $line =~ /^google\.com\.\s+\d+\s+IN\s+A/) {
			print "PARSED: $ip allows recursive lookups\n";
			$y->insert_issue(name => 'dns_rec_lookup', ip_address => $ip, port => 53, transport_protocol => 'UDP');
		}

		# HOSTNAME.BIND.          0       CH      TXT     "somehost"
		if ( $line =~ /^HOSTNAME.BIND.*TXT\s+"([^"]+)"/) {
			my $hostname = $1;
			print "PARSED: Hostname $hostname\n";
			$y->insert_hostname(type => 'hostname_bind', ip_address => $ip, hostname => $hostname);
		}

		# VERSION.BIND.           0       CH      TXT     "4.4.7-REL-NOESW
		if ( $line =~ /^VERSION.BIND.*TXT\s+"(\d\.\d\.[A-Z0-9\.-]+)"/) {
			my $version= $1;
			print "PARSED: Bind Version $version\n";
			$y->insert_port_info(port_info_key => 'bind_version', port_info_value => $version, ip => $ip, port => 53, transport_protocol => "UDP");
			$y->insert_issue(name => 'bind_version_disclosed', ip_address => $ip, port => 53, transport_protocol => 'UDP');
		}

	}

	$y->commit;

}
$y->destroy;
