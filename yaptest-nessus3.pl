#!/usr/bin/perl -w
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
Runs Nessus 3 on open ports (found from backend database).

The the location of the nessus client (normally called 'nessus') 
can be specified using yaptest-config.pl to set 'nessus_client' to the
full path of nessus binary (e.g. /opt/nessus/bin/nessus).  

The Nessus daemon should already have been started and yaptest 
supplied with login credentials for the daemon (use yaptest-config.pl
to set 'nessusd_username' and 'nessusd_password').

Remeber, you can store all this nessus info in ~/yaptestrc so that
it's automatically used in every test without having to use
yaptest-config.pl every time.

NB: SSL Certificate checking is disabled.  This may not be
    what you want.
";
die $usage if shift;
my $y = yaptest->new();

my $nessusd_port           = $y->get_config('nessusd_port');
my $nessusd_ip             = $y->get_config('nessusd_ip');
my $nessusd_username       = $y->get_config('nessusd_username');
my $nessusd_password       = $y->get_config('nessusd_password');
my $nessus_client          = $y->get_config('nessus_client');

if (defined($nessus_client)) {
        print "NOTE: Using nessus client: $nessus_client\n";
} else {
        print "WARNING: nessus_client config option not set.  Use yaptest-config.pl\n";
        print "         to set 'nessus_client' to the location of the nessus client\n";
        print "         Will search for nessus in \$PATH - might not be what you want\n";
        $nessus_client = "nessus";
}
print "\n";

$y->run_test (
	command => "yaptest-nessus-wrapper.pl -c '$nessus_client' -h '$nessusd_ip:$nessusd_port' -u '$nessusd_username' --pass '$nessusd_password' -i ::IP:: --ports ::PORTLIST:: -o nessus-report-::IP::.nbe",
	parallel_processes => $max_processes,
	output_file => "nessus-::IP::.out",
	parser => "yaptest-issues.pl parse nessus-report-::IP::.html"
);

