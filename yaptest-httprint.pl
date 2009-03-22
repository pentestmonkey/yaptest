#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $max_processes = 5;
my $script_name = basename($0);
my $usage = "Usage: $script_name [options]
Runs httprint on any port in database which nmap thinks are HTTP(S) ports.

NB: httprint is required to be in the path.  (http://www.net-square.com/httprint)
    A signature file for httprint is also required.  Use yaptest-config.pl to 
    specify its location:

    \$ yaptest-config.pl query httprint_sig_file
    \$ yaptest-config.pl set httprint_sig_file /usr/local/share/httprint/signatures.txt

";

die $usage if shift;
my $y = yaptest->new();

my $sig_file = $y->get_config('httprint_sig_file');

unless (defined($sig_file)) {
	print "ERROR: No Signature file for httprint has been configured.\n";
	die $usage;
}

$y->run_test(
	command => "httprint -P0 -h http://::IP:::::PORT:: -s $sig_file",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 0 },
	max_lines => 1000,
	inactivity_timeout => 180
);

$y->run_test(
	command => "httprint -P0 -h https://::IP:::::PORT:: -s $sig_file",
	parallel_processes => $max_processes,
	filter => { port_info => "nmap_service_name like http", ssl => 1 },
	max_lines => 1000,
	inactivity_timeout => 180
);


