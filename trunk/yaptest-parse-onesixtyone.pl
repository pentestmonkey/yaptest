#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name ono-output.txt [options]
Read output of onesixtyone and enters data into database.

Options are:
	--help          Print this message
";

GetOptions (
	"help"      => \$help
);

die $usage if $help;
my $file = shift or die $usage;
my $y = yaptest->new();
my $commit = 1;
my $awaiting_rpcinfo_start = 1;
my $awaiting_ip = 2;
my $awaiting_rpc_body = 3;

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";
	unless (open (SNMPFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	
	while (<SNMPFILE>) {
		# print $_;
		chomp $_;
		my $line = $_;
		next if $line =~ /Host responded with error NO SUCH NAME/;
		# 1.2.3.4 [public] Sun SNMP Agent, Sun-Fire-V490
		next unless $line =~ /^(\d+\.\d+\.\d+\.\d+)\s+\[([^]]+)\]\s+(.*)/;
		my $ip = $1;
		my $community = $2;
		my $device_info = $3;
		print "PARSED: IP=$ip, Community=$community\n";
		$y->insert_credential(ip_address => $ip, port => 161, transport_protocol => "UDP", password => $community, credential_type_name => "snmp_community");
		$y->insert_host_info(ip_address => $ip, key => "device_info", value => $device_info);
		$y->insert_issue(name => "snmp_comm_guessed", ip_address => $ip, port => 161, transport_protocol => "UDP");
		if ($line =~ /JETDIRECT/) {
			$y->insert_host_info(ip_address => $ip, key => "device_type", value => 'Printer');
		}
	}
	close SNMPFILE;
}
$y->{dbh}->commit if $commit;

