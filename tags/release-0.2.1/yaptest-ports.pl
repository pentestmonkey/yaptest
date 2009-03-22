#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $test_area;
my $port;
my $ip;
my $rpc_string;
my $service_string;
my $version_string;
my $script_name = basename($0);
my $usage = "Usage: $script_name query [ options ]
Lists open ports found

Options are:
	-i ip          IP to search for
	-p port        Port to search for
	-t test_area   Test area to search for
	-r string      String to search for in 'rpcinfo -p' output (e.g. 'sadmind')
	-s string      String to search for in nmap service string (e.g. 'http')
	-v string      String to search for in nmap version string (e.g. 'Apache')
";

GetOptions (
	"port=s"      => \$port,
	"test_area=s" => \$test_area,
	"ip=s"        => \$ip,
	"rpc=s"       => \$rpc_string,
	"service=s"   => \$service_string,
	"version=s"   => \$version_string
);

my $command = shift or die $usage;

if ($command eq "query" or $command eq "export") {
	my $aref = $y->get_ports(port => $port, ip_address => $ip, test_area => $test_area, rpc_string => $rpc_string, service_string => $service_string, version_string => $version_string);
	if ($command eq "query") {
		$y->print_table_hashes($aref, undef, qw(test_area_name ip_address port transport_protocol));
	}
	if ($command eq "export") {
		my $filename = shift;
		die "ERROR: Filename is mandatory for 'export' command\n" unless defined($filename);
		$y->export_to_xml($aref, "ports", $filename);
		print "Exported query results to $filename\n";
	}
} else {
	die $usage;
}
$y->{dbh}->commit;
