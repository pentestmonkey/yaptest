#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $file;
my @ips;
my $script_name = basename($0);
my $usage = "
Usage: $script_name query [ --test_area test_area ] [ --ip ip ] [ --key key ] [ --value value ]
       $script_name export out.xml [ --test_area test_area ] [ --ip ip ] [ --key key ] [ --value value ]
       $script_name add [ --test_area test_area ] --ip ip --key key --value value

key is one of:
	windows_domwkg   The windows domain / workgroup
	os               Operating system
	windows_dc       Set to domain only if IP is a Domain Controller

Displays information about IPs in database.  
";

my ($ip, $test_area, $key, $value);
GetOptions (
	"ip=s" => \$ip,
	"test_area=s" => \$test_area,
	"key=s" => \$key,
	"value=s" => \$value,
);

my $command = shift or die $usage;

if ($command eq "query" or $command eq "export") {
	my $aref = $y->get_host_info(test_area => $test_area, ip_address => $ip, key => $key, value => $value);
	if ($command eq "query") {
		$y->print_table_hashes($aref, undef, qw(test_area_name ip_address key value));
	}
	if ($command eq "export") {
		my $filename = shift;
		die "ERROR: filename is mandatory for 'export' command\n" unless defined($filename);
		$y->export_to_xml($aref, "host_info", $filename);
		print "Exported query results to $filename\n";
	}
} elsif ($command eq "add") {
	$y->insert_host_info(test_area => $test_area, ip_address => $ip, key => $key, value => $value);
	print "Successfully associated $key => $value with $ip\n";
} else {
	die $usage;
}
$y->{dbh}->commit;
