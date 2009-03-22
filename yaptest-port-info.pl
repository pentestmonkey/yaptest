#!/usr/bin/env perl 
use strict;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $file;
my $port;
my $transport_protocol;
my @ips;
my $script_name = basename($0);
my $usage = "
Usage: $script_name query [ --test_area test_area ] [ --ip ip ] [ --port port ] [ --trans {tcp|udp} ] [ --key key ] [ --value value ]
       $script_name export [ --test_area test_area ] [ --ip ip ] [ --port port ] [ --trans {tcp|udp} ] [ --key key ] [ --value value ]
       $script_name add [ --test_area test_area ] --ip ip [ --port port ] [ --trans {tcp|udp} ] --key key --value value

key is one of:
	nmap_service     What nmap identified the service as (e.g. http)
	nmap_version     Version of service from nmap (e.g. Apache/2.0.52)

Displays information about ports in database.  
";

my ($ip, $test_area, $key, $value);
GetOptions (
	"ip=s" => \$ip,
	"test_area=s" => \$test_area,
	"key=s" => \$key,
	"trans=s" => \$transport_protocol,
	"port=s" => \$port,
	"value=s" => \$value,
);

my $command = shift or die $usage;

if ($command eq "query" or $command eq "export") {
	my $aref = $y->get_port_info(test_area => $test_area, ip => $ip, port => $port, transport_protocol => $transport_protocol, port_info_key => $key, value => $value);
	if ($command eq "query") {
		$y->print_table_hashes($aref, undef, qw(test_area_name ip_address port transport_protocol port_info_key value));
	}
	if ($command eq "export") {
		my $filename = shift;
		die "ERROR: Filename is mandatory for 'export' command\n" unless defined($filename);
		$y->export_to_xml($aref, "port_info", $filename);
		print "Exported query results to $filename\n";
	}
} elsif ($command eq "add") {
	$y->insert_port_info(test_area => $test_area, ip => $ip, port => $port, transport_protocol => $transport_protocol, port_info_key => $key, port_info_value => $value);
	print "Successfully associated $key => $value with $ip\n";
} else {
	die $usage;
}
$y->{dbh}->commit;
