#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses nfsshell ('nfs') to mount each exported directory.

[ This script is a work in progress ]

NB: yaptest-nfs-wrapper.pl and nfs need to be in your path.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command     => 'yaptest-nfs-wrapper.pl ::IP:: "::PORTINFO-nfs_export::"',
	filter      => { port_info => 'nfs_export LIKE /' }, # TODO kludge: API needs this or it will select from view_port instead of view_port_info
	output_file => 'nfs-::IP::.out', # TODO remove '/' from export name and embed in filename
	parser      => "yaptest-parse-nfs.pl"
);
