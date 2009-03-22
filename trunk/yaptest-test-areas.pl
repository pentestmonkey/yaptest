#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;
use Data::Dumper;
use Getopt::Long;

my $description;
my $script_name = basename($0);
my $usage = "Usage: 
     $script_name new --desc \"description\" test-area yaptest.conf
     $script_name query 
     $script_name update --desc \"description\" test-area

Creates a new test area within an existing database or modifies the 
description for a test area.

Recommended usage:

First use yaptest-new-db.pl to create a new database.  Then:
\$ mkdir vlan1; cd vlan1
\$ $script_name new --desc \"Main User LAN\" vlan1 yaptest.conf
\$ source env.sh

This will create the files yaptest.conf and env.sh in the
current directory.  These have the same use as for 
yaptest-new-db.pl - see it's help message.

To change the description for a test area:

\$ $script_name update --desc \"description\" test-area

The description set with -d is used in reports (yaptest-reports.pl).

To list the test areas and descriptions:

\$ $script_name query

";

GetOptions (
	"desc=s" => \$description
);

my $command = shift or die $usage;

my $y = yaptest->new();
if ($command eq "new") {
	# Create a new test area
	my $test_area = shift or die $usage;
	my $config_file = shift or die $usage;
	die $usage if shift;
	die $usage unless (defined($test_area) and defined($config_file));
	$y->insert_test_area(name => $test_area, description => $description, config_file => $config_file);
	$y->set_test_area($test_area);
} 

if ($command eq "update") {
	# Change the description for a test area
	my $test_area = shift or die $usage;
	die $usage if shift;
	die $usage unless (defined($test_area) and defined($description));
	$y->insert_test_area(name => $test_area, description => $description);
	print "Successfully set description on test area $test_area\n";
}

if ($command eq "query") {
	die $usage if shift;
	$y->print_table_hashes($y->get_test_areas, undef, qw(name description));
}

$y->{dbh}->commit;

