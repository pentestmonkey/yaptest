#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $test_area;
my $type;
my $ip;
my $rpc_string;
my $script_name = basename($0);
my $usage = "Usage: $script_name query [ options ]
Lists hosts that respond to ICMP requests

Options are:
	--ip        ip          IP to search for
	--type      type        Type of ICMP response (echo, time, addr, info)
	--test_area test_area   Test area to search for
";

GetOptions (
	"type=s"      => \$type,
	"test_area=s" => \$test_area,
	"ip=s"        => \$ip,
);

my $command = shift or die $usage;

if ($command eq "query") {
	my $aref = $y->get_icmp(type => $type, ip_address => $ip, test_area => $test_area);
	$y->print_table_hashes($aref, undef, qw(test_area_name ip_address host_name icmp_name));
} else {
	die $usage;
}
$y->{dbh}->commit;
