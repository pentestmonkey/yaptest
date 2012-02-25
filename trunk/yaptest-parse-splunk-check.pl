#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name splunk-check-http[s]-10.0.0.1-8089.out [ splunk-check-http[s]-10.0.0.2-8000.out ]

Parses splunk-check.pl output and adds issues to databases.  IP and port must be in the filename.
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
		chomp;
		my $line = $_;
		if ($line =~ /Splunk forwarder detected/) {
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_forwarder", port_info_value => 1);
		}
		if ($line =~ /Splunk management server detected/) {
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_management", port_info_value => 1);
		}
		if ($line =~ /Splunk Version .* Build (\d+)/) {
			my $build = $1;
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_build", port_info_value => $build);
		}
		if ($line =~ /Splunk Version ([\d\.]+) /) {
			my $version= $1;
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_version", port_info_value => $version);
		}
		if ($line =~ /Logged into .* with default credentials: (.*)\/(.*)/) {
			my $user = $1;
			my $pass = $1;
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_default_creds", port_info_value => 1);
			$y->insert_credential(ip_address => $ip, port => $port, transport_protocol => "TCP", password => $pass, username => $user, credential_type_name => "splunk_login");
		}
		if ($line =~ /Remote logins not allowed, but default credentials are in use for .*: (.*)\/(.*)/) {
			my $user = $1;
			my $pass = $1;
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => "TCP", port_info_key => "splunk_default_creds", port_info_value => 1);
			$y->insert_credential(ip_address => $ip, port => $port, transport_protocol => "TCP", password => $pass, username => $user, credential_type_name => "splunk_login");
		}
		# TODO vulnerable version info
	}
}
$y->commit;
$y->destroy;
