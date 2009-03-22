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
Runs OpenVAS on open ports (found from backend database).

The the location of the openvas client (normally called 'OpenVAS-Client') 
can be specified using yaptest-config.pl to 'openvas' client to the
full path of openvas binary (e.g. /opt/openvas/bin/openvas).  

The OpenVAS daemon should already have been started and yaptest 
supplied with login credentials for the daemon (use yaptest-config.pl
to set 'openvasd_username' and 'openvasd_password').

Remeber, you can store all this openvas info in ~/yaptestrc so that
it's automatically used in every test without having to use
yaptest-config.pl every time.

NB: SSL Certificate checking is disabled.  This may not be
    what you want.
";
die $usage if shift;
my $y = yaptest->new();

my $openvasd_port           = $y->get_config('openvasd_port');
my $openvasd_ip             = $y->get_config('openvasd_ip');
my $openvasd_username       = $y->get_config('openvasd_username');
my $openvasd_password       = $y->get_config('openvasd_password');
my $openvas_client          = $y->get_config('openvas_client');

if (defined($openvas_client)) {
        print "NOTE: Using openvas client: $openvas_client\n";
} else {
        print "WARNING: openvas_client config option not set.  Use yaptest-config.pl\n";
        print "         to set 'openvas_client' to the location of the openvas client\n";
        print "         Will search for openvas in \$PATH - might not be what you want\n";
        $openvas_client = "openvas";
}
print "\n";

$y->run_test (
	command => "yaptest-nessus-wrapper.pl -c '$openvas_client' -h '$openvasd_ip:$openvasd_port' -u '$openvasd_username' --pass '$openvasd_password' -i ::IP:: --ports ::PORTLIST:: -o openvas-report-::IP::.nbe",
	parallel_processes => $max_processes,
	output_file => "openvas-::IP::.out",
	parser => "yaptest-issues.pl parse"
);

