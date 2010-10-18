#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Tries TFTP uploads and runs tftpbrute.pl to attempt to download
each file in download-files.txt.  Tests are run on all host with
port 69/UDP open.

A dictionary of file names is required.  This can be configured
with yaptest-config.pl:
\$ yaptest-config.pl query dict_tftp_files
\$ yaptest-config.pl set dict_tftp_files /home/u/dicts/tftp-files.txt

NB: tftp and tftpbrute.pl are required to be in the path.
";

die $usage if shift;
my $y = yaptest->new();
my $dictionary_file = $y->get_config('dict_tftp_files');

unless (defined($dictionary_file)) {
	print "ERROR: No dictionary has been configured for tftpbrute.\n";
	die $usage;
}

$y->run_test(
	command => "tftpbrute.pl ::IP:: $dictionary_file 1",
	filter => { port => 69, transport_protocol => 'udp' },
	parallel_processes => 10,
);

system("echo testing > tftp-test.txt");

$y->run_test(
	command => "echo put tftp-test.txt | tftp ::IP::",
	filter => { port => 69, transport_protocol => 'udp' },
	parallel_processes => 10,
	output_file => 'tftp-get-::IP::.out'
);

$y->run_test(
	command => "echo get tftp-test.txt | tftp ::IP::",
	filter => { port => 69, transport_protocol => 'udp' },
	parallel_processes => 10,
	output_file => 'tftp-get-::IP::.out'
);

unlink("tftp-test.txt");
