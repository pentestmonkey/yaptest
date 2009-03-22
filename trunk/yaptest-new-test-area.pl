#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name -d \"description\" test-area yaptest.conf
Creates a new test area within an existing database.

Recommended usage:

First use yaptest-new-db.pl to create a new database.  Then:
\$ mkdir vlan1; cd vlan1
\$ $script_name vlan1 yaptest.conf
\$ source env.sh

This will create the files yaptest.conf and env.sh in the
current directory.  These have the same use as for 
yaptest-new-db.pl - see it's help message.

The description set with -d is used in reports (yaptest-reports.pl).
";

my $test_area = shift or die $usage;
my $config_file = shift or die $usage;
die $usage if shift;
my $y = yaptest->new();
$y->insert_test_area($test_area, $config_file);
$y->set_test_area($test_area);
