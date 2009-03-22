#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $file;
my $test_area;
my @ips;
my $script_name = basename($0);
my $usage = "Usage: $script_name add ( ip [ ip ... ] | -f ips.txt)
$script_name query [ -i ip ] [ -t test_area ]
$script_name export out.xml [ -i ip ] [ -t test_area ]
$script_name delete ip [ ip ] ...

Adds, removed and queries IPs in the database.
";

GetOptions (
	"file=s" => \$file,
	"test_area=s" => \$test_area,
	"ip=s" => \@ips,
);

my $command = shift or die $usage;

if ($command eq "add") {
	if ($file) {
		open FILE, "<$file" or die "ERROR: Can't open $file for reading: $!\n";
		while (<FILE>) {
			chomp;
			my $ip = $_;
			print "Inserting $ip\n";
			$y->insert_ip($ip);
		}
	} else {
		unless (@ARGV) {
			die $usage;
		}
		foreach my $ip (@ARGV) {
			print "Inserting $ip\n";
			$y->insert_ip($ip);
		}
	}
} elsif ($command eq "query" or $command eq "export") {
	die $usage if (scalar(@ips) > 1); # must have 0 or 1 IPs
	my $aref = $y->get_hosts(test_area => $test_area, ip_address => $ips[0]);
	if ($command eq "query") {
		$y->print_table_hashes($aref, undef, qw(test_area_name ip_address hostname name_type));
	}
	if ($command eq "export") {
		my $filename = shift;
		die "ERROR: filename is mandatory for 'export' command\n" unless defined($filename);
		$y->export_to_xml($aref, "hosts", $filename);
		print "Exported query results to $filename\n";
	}
} elsif ($command eq "delete") {
	unless (@ARGV) {
		die $usage;
	}
	foreach my $ip (@ARGV) {
		print "Deleting $ip\n";
		$y->delete_host(test_area => $test_area, ip_address => $ip);
	}
} else {
	die $usage;
}
$y->{dbh}->commit;
