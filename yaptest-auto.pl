#!/usr/bin/env perl
#
#
#The following config lines in yaptest.conf allow differernt tests to be performed
#
#
### - General options
#
# auto-traceroute = 0/1 turns traceroute tests on or off - default on
# auto-nmap-proto = 0/1 turns nmap protocol scans on and off - default on
# auto-ping-r = 0/1 turns ping-r tests on or off - deault on
#
### - Password Guessing
#
# auto-password-guess = 0/1 turns on the ability to auto perform password guessing - default off
# (This has to be on for any password guessing to take place)
#
# auto-password-guess-ftp = 0/1 - default off
# auto-password-guess-mssql = 0/1 - default off
# auto-password-guess-rlogin = 0/1 - default off
# auto-password-guess-smb = 0/1 - default off
# auto-password-guess-ssh = 0/1 - default off
#
### - Nessus
#
# auto-nessus = 0/1 - default on
#
#
### - Tools
#
# auto-hoppy = 0/1 - default on
# auto-nikto = 0/1 - default on
#
#
### TODO
# 1 - add openvas checks
#



use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;
use Parallel::ForkManager;
use Proc::Simple;

my $run = 0;
my $max_processes = 5;
my $help = 0;
my $script_name = basename($0);
my $usage = "Usage: $script_name
Runs all the different yaptest scripts in an automated way.

";

die $usage if shift;
my $y = yaptest->new();

#Check we are running as root
if($< != 0)
{
	print "Error: You need to run this as root!\n";
	exit();
}


# Quick TCP portscan followed by 
system("yaptest-dns-grind-ptr.pl");         # Get DNS PTR records
system("yaptest-yapscan-tcp.pl quick"); # Quick TCP port scan

#start the full tcp, but dont wait for it finish untill later
my $procfulltcp = Proc::Simple->new();
$procfulltcp->start("yaptest-yapscan-tcp.pl full");

#No need to wait for the results now

#start the udp scans in the background
my $procudp1 = Proc::Simple->new();
my $procudp2 = Proc::Simple->new();
$procudp1->start("yaptest-nmap-udp.pl");
$procudp2->start("yaptest-udp-proto-scanner.pl");

# start other tests in the back gound, these are not dependent on ports

my $runPing_r = 1;
my $runNmap_proto = 1;

if(defined($y->get_config('auto-ping-r')))
{
	if($y->get_config('auto-ping-r') == 0)
        {
		$runPing_r = 0;
	}
}

if(defined($y->get_config('auto-nmap-proto')))
{
        if($y->get_config('auto-nmap-proto') == 0)
        {
                $runNmap_proto = 0;
        }
}

my $procIke = Proc::Simple->new();
$procIke->start("yaptest-ike-scan.pl");
my $procIcmp = Proc::Simple->new();
$procIcmp->start("yaptest-yapscan-icmp.pl");
my $procPing_r = Proc::Simple->new();
if($runPing_r)
{	
	$procPing_r->start("yaptest-ping-r.pl");
}
my $proc161 = Proc::Simple->new();
$proc161->start("yaptest-onesixtyone.pl");
my $procNmap_proto = Proc::Simple->new();
if($runNmap_proto)
{
	$procNmap_proto->start("yaptest-nmap-ip-protocols.pl");
}

# Perform traceroutes
if(defined($y->get_config('auto-traceroute')))
{
	if($y->get_config('auto-traceroute') == 1)
	{
		 system('yaptest-traceroute.pl');
	}
}
else
{
	 system('yaptest-traceroute.pl');
}

system('yaptest-nbtscan.pl');           # Get windows hostname info

#run the tcp based tests on the ports we have found so far
tcp_port_based_tests();

# Run the password guess tasks
password_guessing();


# wait for the full tcp scans to come back
$procfulltcp->wait();

# run nessus, background it as it can take quite some time!
my $runNessus = 1;

if(defined($y->get_config('auto-nessus')))
{
        if($y->get_config('auto-nessus') != 1)
        {
                 $runNessus = 0;
        }
}

my $runhoppy = 1;
if(defined($y->get_config('auto-hoppy')))
{
        if($y->get_config('auto-hoppy') != 1)
        {
                 $runhoppy = 0;
        }
}

my $runNikto = 1;
if(defined($y->get_config('auto-nikto')))
{
        if($y->get_config('auto-nikto') != 1)
        {
                 $runNikto = 0;
        }
}

my $procNessus = Proc::Simple->new();

if($runNessus)
{
	$procNessus->start("yaptest-nessus3.pl");	
}

#wait for the udpscans to finish
$procudp1->wait();
$procudp2->wait();
#run the udp based tests
system("yaptest-parse-nmap-xml.pl nmap-udp*.xml");
# run the tests based on udp ports
udp_port_based_tests();

#
# Banner grab on all open ports
#
system("yaptest-bannergrab.pl");

#
# Run the tests based on nmap service identifcation
#
nmap_service_based_tests();

# rerun the tcp port based tests
# yaptest will only test the new ports listsed
tcp_port_based_tests();


#wait for the nessus scans to finish
if($runNessus)
{
	$procNessus->wait();
	system("yaptest-issues.pl parse nessus-report-*.nbe");
}

#
# Wait for all the back gound process to finish
#
$procIke->wait();
$procIcmp->wait();
if($runPing_r)
{
        $procPing_r->wait();
}
$proc161->wait();
if($runNmap_proto)
{
        $procNmap_proto->wait();
}

#
#find all the insecure protocols used
#
system("yaptest-issues.pl insecgen");

# 
# Perfom clean up
#
#delete all zero sized files
system("find . -size 0 -exec rm {} +;");

#
# Subs be below here
#

#
# tcp port based tests
#

sub tcp_port_based_tests
{
	my @torun;

	push(@torun, "yaptest-rpcinfo.pl");
	push(@torun, "yaptest-amap-tcp.pl");
        push(@torun, "yaptest-nxscan.pl");
        push(@torun, "yaptest-ms08-067-check.pl");
        push(@torun, "yaptest-ident-user-enum.pl");
        push(@torun, "yaptest-dcetest.pl");
        push(@torun, "yaptest-nmap-tcp.pl openonly");
        push(@torun, "yaptest-tnscmd.pl");
        push(@torun, "yaptest-oscanner.pl");
        push(@torun, "yaptest-finger-user-enum.pl");
        push(@torun, "yaptest-smtp-user-enum.pl");
        
        push(@torun, "yaptest-vessl.pl");
        push(@torun, "yaptest-httprint.pl");
        push(@torun, "yaptest-smtpscan.pl");

        push(@torun, "yaptest-x-open.pl");
        push(@torun, "yaptest-enum4linux.pl");
        push(@torun, "yaptest-ssh-keyscan.pl");
        push(@torun, "yaptest-sshprobe.pl");
	push(@torun, "yaptest-rexd.pl");
        push(@torun, "yaptest-kcmsd-fileread.pl");
        push(@torun, "yaptest-showmount.pl");
        push(@torun, "yaptest-nfs.pl");
        push(@torun, "yaptest-rup.pl");
        push(@torun, "yaptest-rusers.pl");

	my $pm = new Parallel::ForkManager($max_processes); 

  	foreach my $run (@torun) 
	{
		$pm->start and next;
		system($run);
		$pm->finish;
	}
	$pm->wait_all_children;
	system("yaptest-parse-nmap-xml.pl nmap-tcp*.xml");
}

#
# Tests on rpc
#
sub rpcinfo_based_tests
{
	my @torun;
	
	push(@torun, "yaptest-rexd.pl");
	push(@torun, "yaptest-kcmsd-fileread.pl");
	push(@torun, "yaptest-showmount.pl");
	push(@torun, "yaptest-rup.pl");
	push(@torun, "yaptest-rusers.pl");

	my $pm = new Parallel::ForkManager($max_processes);

        foreach my $run (@torun)
        {
                $pm->start and next;
                system($run);
                $pm->finish;
        }
        $pm->wait_all_children;
}

#
# Password guessing on services
#
sub password_guessing
{

	my @torun;

	#We do not want password guessing by default
	if(defined($y->get_config('auto-password-guess')))
	{
        	if($y->get_config('auto-password-guess') == 1)
        	{
                 	#Perform ftp password guessing
			if(defined($y->get_config('auto-password-guess-ftp')))
			{
				if($y->get_config('auto-password-guess-ftp') == 1)
				{
					push(@torun, "yaptest-password-guess-ftp.pl");
				}
			}

			#Perform mssql password guessing
			if(defined($y->get_config('auto-password-guess-mssql')))
                        {
                                if($y->get_config('auto-password-guess-msql') == 1)
                                {
                                        push(@torun, "yaptest-password-guess-msql.pl");
                                }
                        }

			
                        #Perform rlogin password guessing
                        if(defined($y->get_config('auto-password-guess-rlogin')))
                        {
                                if($y->get_config('auto-password-guess-rlogin') == 1)
                                {
                                        push(@torun, "yaptest-password-guess-rlogin.pl");
                                }
                        }

			
                        #Perform smb password guessing
                        if(defined($y->get_config('auto-password-guess-smb')))
                        {
                                if($y->get_config('auto-password-guess-smb') == 1)
                                {
                                        push(@torun, "yaptest-password-guess-smb.pl");
                                }
                        }

			
                        #Perform ssh password guessing
                        if(defined($y->get_config('auto-password-guess-ssh')))
                        {
                                if($y->get_config('auto-password-guess-ssh') == 1)
                                {
                                        push(@torun, "yaptest-password-guess-ssh.pl");
                                }
                        }

			my $pm = new Parallel::ForkManager($max_processes);

        		foreach my $run (@torun)
        		{
                		$pm->start and next;
                		system($run);
                		$pm->finish;
        		}
        		$pm->wait_all_children;
        	}
	}

}

#
# Tests based on udp ports
#
sub udp_port_based_tests
{
	my @torun;

	push(@torun, "yaptest-amap-udp.pl");
        push(@torun, "yaptest-fpdns.pl");
        push(@torun, "yaptest-dns.pl");
        push(@torun, "yaptest-ntp.pl");
        push(@torun, "yaptest-tftp.pl");
	push(@torun, "yaptest-snmpwalk.pl");

	my $pm = new Parallel::ForkManager($max_processes);

	foreach my $run (@torun)
        {
        	$pm->start and next;
                system($run);
                $pm->finish;
        }
        $pm->wait_all_children;
}

#
# Tests which are dependent on nmap service findings
#
sub nmap_service_based_tests {
	
	my @torun;

	push(@torun, "yaptest-ldapsearch.pl");
	push(@torun, "yaptest-telnet-fuser.pl");
	if($runNikto)
	{
		    push(@torun, "yaptest-nikto.pl");
	}
	if($runhoppy)
	{
		    push(@torun, "yaptest-hoppy.pl");
	}
	push(@torun, "yaptest-sslscan.pl")


	my $pm = new Parallel::ForkManager($max_processes);

        foreach my $run (@torun)
        {
                $pm->start and next;
                system($run);
                $pm->finish;
        }
        $pm->wait_all_children;
}


#yaptest-openvas.pl

