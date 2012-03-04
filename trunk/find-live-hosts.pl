#!/usr/bin/perl -w
use strict;
use POSIX;
use IO::Pty;
use Getopt::Std;
use Data::Dumper;

my $yapscan = "yapscan";
my $udp_app_scan = "udp-proto-scanner.pl";
my $iface = "eth0";
my $bandwidth = "500000";
my $verbose = 0;
my $quiet = 0;
my $tcpscan = 1;
my $udpscan = 1;
my $icmpscan = 1;
my $outputfile = undef;

my $usage = "Runs some ICMP, TCP and UDP scans to find hosts that are up.
Usage: $0 [ options ] ips-file

If you're scanning a remote network (i.e. one which you can't arp-scan), then this
script should be run in order to identify live hosts to be passed to yaptest.

Example:
find-live-hosts.pl -i eth1 -o live-ips.txt -v loads-of-ips.txt
yaptest-hosts.pl add -f live-ips.txt

Options are:
     -o file       Output file to store live host ips in (default: none)
     -i iface      Interface for scanning (default: $iface)
     -b bandwidth  Bandwidth for scanning in bits/sec (default: $bandwidth)
     -T 0|1        Turn on or off a TCP scan of around 100 common ports (default: $tcpscan)
     -I 0|1        Turn on or off an ICMP scan for echo, timestamp, addrmask and info (default: $icmpscan)
     -U 0|1        Turn on or off UDP scans for common protocols like DNS, MSSQL (default: $udpscan)
     -q            Quiet
     -v            Verbose

NB: Depends on yapscan and udp-proto-scanner.pl.  Yapscan doesn't work on OSX, so 
    this script will only be of use to Linux users.

";

my $pty;
my %hosts;

# Process command line options
my %opts;
getopts('o:i:b:vqT:U:I:', \%opts);
$iface     = $opts{'i'} if $opts{'i'};
$bandwidth = $opts{'b'} if $opts{'b'};
$verbose   = 1 if $opts{'v'};
$quiet     = 1 if $opts{'q'};
$tcpscan   = $opts{'T'} if defined($opts{'T'});
$udpscan   = $opts{'U'} if defined($opts{'U'});
$icmpscan  = $opts{'I'} if defined($opts{'I'});
$outputfile= $opts{'o'} if $opts{'o'};
my $ips_file = shift or die $usage;

# Check we're root
unless (geteuid() == 0) {
        print "ERROR: You need to be root.  (To send raw packets and sniff)\n";
	exit 1;
}

# Find hosts that respond to ICMP
$icmpscan && do_cmd("$yapscan -sI -b " . int($bandwidth / 10) . " -i $iface -t - -r4 -f $ips_file");

# Find hosts with open or closed TCP ports
$tcpscan && do_cmd("$yapscan -sS -c -b $bandwidth -i $iface -P common -r 2 -f $ips_file");

# Find hosts that respond to app-specific UDP probes
$udpscan && do_cmd("$udp_app_scan --bandwidth $bandwidth -p all -f $ips_file");

show_results();

sub show_results {
	printf "[+] %d live hosts found:\n", scalar(keys %hosts) unless $quiet;
	print join("\n", ipsort(keys %hosts)) . "\n" unless $quiet;	

	if (defined($outputfile)) {
		open FILE, ">$outputfile" or die "ERROR: Can't open output file $outputfile for writing: $!\n";
		print FILE join("\n", ipsort(keys %hosts)) . "\n";
		close FILE;
	}
}

sub ipsort {
	my @list = @_;

	my @list_char_prefix = sort map { (pack "C4", split(/\./, $_) ) . $_ } @list;
	return map { substr $_, 4 } @list_char_prefix;
}

# From Network Programming with PERL
# http://www.modperl.com/perl_networking/sample/ch6.html
sub do_cmd {
	my ($cmd,@args) = @_;
	print "[+] Running command: $cmd\n" unless $quiet;
	my $pty = IO::Pty->new or die "can't make Pty: $!";
	defined (my $child = fork) or die "Can't fork: $!";
	if ($child) {
		$pty->close_slave();
		# return $pty;
		while (<$pty>) {
			my $line = $_;
			print $line if $verbose;
			if ($line =~ /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/ or $line =~ /Received reply to probe .* \(target port \d+\) from (\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}):\d+/) {
				my $ip = $1;
				print "$ip\n" unless ($verbose or $hosts{$ip});
				$hosts{$ip} = 1;
			}
		}
		return 0;
	}
	
	POSIX::setsid();
	my $tty = $pty->slave;
	$pty->make_slave_controlling_terminal();
	close $pty;
	
	STDIN->fdopen($tty,"<")      or die "STDIN: $!";
	STDOUT->fdopen($tty,">")     or die "STDOUT: $!";
	STDERR->fdopen(\*STDOUT,">") or die "STDERR: $!";
	close $tty;
	$| = 1;
	exec $cmd,@args;
	die "Couldn't exec: $!";
}

