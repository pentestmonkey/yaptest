#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs enum4linux IPs in database with ports 139 or 445/TCP open.

A dictionary of share names is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_smb_shares
\$ yaptest-config.pl set dict_smb_shares /home/u/dicts/smb_shares.txt

NB: enum4linux is required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $share_file = $y->get_config('dict_smb_shares');

unless (defined($share_file)) {
	print "ERROR: No dictionary has been configured for enum4linux.\n";
	die $usage;
}

$y->run_test(
	command            => "enum4linux.pl -a -d -R 500-550,1000-1150 -s $share_file ::IP::",
	filter             => { port => [139, 445], transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'enum4linux-::IP::.out',
	parser             => "yaptest-parse-enum4linux.pl"
);
