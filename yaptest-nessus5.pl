#!/usr/bin/env perl
use strict;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $run = 0;
my $max_processes = 5;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs Nessus 5 on open ports (found from backend database).

The Nessus daemon should already have been started and yaptest 
supplied with login credentials for the daemon (use yaptest-config.pl
to set 'nessusd5_username' and 'nessusd5_password').

Remeber, you can store all this nessus info in ~/yaptestrc so that
it's automatically used in every test without having to use
yaptest-config.pl every time.

NB: SSL Certificate checking is disabled.  This may not be
    what you want.
";
die $usage if shift;
my $y = yaptest->new();

my $nessusd_port           = $y->get_config('nessusd5_port');
my $nessusd_ip             = $y->get_config('nessusd5_ip');
my $nessusd_username       = $y->get_config('nessusd5_username');
my $nessusd_password       = $y->get_config('nessusd5_password');
my $testarea               = $y->get_config('yaptest_test_area');
my $dbname                 = $y->get_config('yaptest_dbname');

unless (defined($nessusd_port) and defined($nessusd_ip) and defined($nessusd_username) and defined($nessusd_password)) {
        print "WARNING: nessus config options not set.  Use yaptest-config.pl\n";
        print "         to set nessusd5_port, nessusd5_ip, nessusd5_username and nessusd5_password\n";
        print "         or edit yaptest.conf\n";
}
print "\n";

$y->run_test (
	command => "yaptest-nessus5-wrapper.pl -h '$nessusd_ip:$nessusd_port' -u '$nessusd_username' --pass '$nessusd_password' -i ::IP:: --ports ::PORTLIST:: -t '$testarea' -d '$dbname' -o nessus-report-::IP::", 
	parallel_processes => $max_processes,
	output_file => "nessus-::IP::.out",
	parser => "yaptest-issues.pl parse nessus-report-::IP::.html"
);

