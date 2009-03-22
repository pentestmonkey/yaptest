#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name dict.txt
Performs SNMP community name guessing on the IPs in the database

A dictionary of SNMP communities is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_snmp
\$ yaptest-config.pl set dict_snmp /home/u/dicts/snmp.txt

NB: onesixtyone is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $dictionary_file = $y->get_config('dict_snmp');

unless (defined($dictionary_file)) {
	print "ERROR: No dictionary has been configured for onesixtyone.\n";
	die $usage;
}

$y->run_test(
	command => "onesixtyone -c $dictionary_file -i ::IPFILE::",
	parser  => "yaptest-parse-onesixtyone.pl"
);
