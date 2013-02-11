#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use IPC::SysV qw(IPC_CREAT SEM_UNDO);
use Digest::MD4 qw(md4 md4_hex md4_base64);
use File::Temp qw/ tempfile /;
use Net::Nessus::XMLRPC;
use Data::Dumper;

# Disable checking of Nessus's SSL cert - may not be what you want.
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $port = 8834;
my $polltime = 15; # seconds
my $nessus_host;
my $username;
my $password;
my $yaptest_policy_name = "yaptest";
my $scan_prefeix = "yaptest",
my $delimeter = "-";
my $test_area;
my $target;
my $ports;
my $outfile;
my $yaptest_db;
my $unique_id = $$;
my $usage = "
Usage: $0 -h ip[:port] -u user --pass pass -i ip -t test_area -d db_name --ports port1,port2,... -o outfile_stem

This script talks XMLRPC with the Nessus 5 server.  It is used by yaptest-nessus5.pl and 
should not be called directly.

All arguments are mandatory and have the following meaning:
    -h   Hostname of nessus server.  Optionally specify a port (default: $port)
    -u   Username to log into nessus server
    -p   Password to log into nessus server
    -i   IP Address to scan
    -o   String on which to base report filenames
    -p   Ports to scan (command separated list of TCP and UDP ports)
    -t   Test area name - for nessus task naming only
    -d   Database name - for nessus task naming only
";

GetOptions (
        "host=s"      => \$nessus_host,
        "user=s"      => \$username,
        "pass=s"      => \$password,
        "ip=s"        => \$target,
        "ports=s"     => \$ports,
        "outfile=s"   => \$outfile,
        "test_area=s" => \$test_area,
        "db_name=s"   => \$yaptest_db,
);

unless (defined($nessus_host) and defined($port) and defined($username) and defined($password) and defined($ports) and defined($outfile) and defined($test_area) and defined($yaptest_db)) {
	print "ERROR: Missing arguments\n";
	print $usage;
	exit 1;
}

if ($nessus_host =~ /([0-9a-zA-Z_\.-]+):(\d+)/) {
	$nessus_host = $1;
	$port = $2;
}

my $scan_name = join($delimeter, $scan_prefeix, $yaptest_db, $test_area, $target, $unique_id);
my $policy_name = join($delimeter, $scan_prefeix, $yaptest_db, $test_area, $target, "policy", $unique_id);

print "\n";
print "Nessus host:       $nessus_host\n";
print "Nessus port:       $port\n";
print "Nessus user:       $username\n";
print "Nessus pass:       $password\n";
print "Target:            $target\n";
print "Port list:         $ports\n";
print "Output file:       $outfile\n";
print "Nessus scan name:  $scan_name\n";
print "Nessus policyname: $policy_name\n";
print "\n";

# Log in to nessus
# my $n = Net::Nessus::XMLRPC->new ("https://$nessus_host:$port", $username, $password);
my $n = Net::Nessus::XMLRPC->new ("https://$nessus_host:$port", $username, $password);
$n->{_ua}->cookie_jar( {} ); # save the authentication cookie
$n->login($username, $password);
unless ($n->logged_in) {
	print "ERROR: Cannot login to: ".$n->nurl.".  Check nessus username, password, host are correct in yaptest.conf.\n";
	exit 1;
}
printf "[+] Logged in to: %s\n", $n->nurl;

# Look up yaptest policy.
my $yaptest_policy_id = $n->policy_get_id($yaptest_policy_name);
if (defined($yaptest_policy_id) and $yaptest_policy_id) {
	printf "[+] Found yaptest policy ID: %s\n", $yaptest_policy_id;
} else {
	print "ERROR: You must create a nessus policy called \"yaptest\"\n";
	exit 1;
}

# Clone yaptest policy and set ports to scan
my $params = $n->policy_get_opts($yaptest_policy_id);
$params->{port_range} = $ports;
$params->{policy_name} = $policy_name;
my $params_dup = $n->policy_new($params);
unless (defined($params_dup) and $params_dup) {
	print "ERROR: Creating new policy failed\n";
	exit 1;
}
my $p = $n->policy_get_id($policy_name);
printf "[+] Created new policy: %s (ID: %s)\n", $policy_name, $p;

# Start scan
printf "[+] Starting scan \"%s\".  Target: %s\n", $scan_name, $target;
my $scanid = $n->scan_new(
	$p,
	$scan_name,
	$target
);
unless (defined($scanid) and $scanid) {
	print "ERROR: Could not start scan: $scan_name\n";
}
printf "[+] Scan ID: %s\n", $scanid;

# Wait for scan to finish
while (not $n->scan_finished($scanid)) {
	print "[+] Polling scan $scanid: " . $n->scan_status($scanid) . "\n";
	sleep $polltime;
}
print "[+] Polling scan $scanid: ".$n->scan_status($scanid)."\n";

printf "[+] Delete temporary policy: %s\n", $p;
$n->policy_delete($p);

# Save output in v1 format
my $reportcont1 = $n->report_file_download($scanid);
my $reportfile1 = "$outfile-v1.xml";
open (FILE,">$reportfile1") or die "Cannot open file $reportfile1: $!";
printf "[+] Saving XMLv1 format to: %s\n", $reportfile1;
print FILE $reportcont1;
close (FILE);

# Save output in v2 format
my $reportcont2 = $n->report_file1_download($scanid);
my $reportfile2 = "$outfile-v2.xml";
open (FILE,">$reportfile2") or die "Cannot open file $reportfile2: $!";
printf "[+] Saving XMLv2 format to: %s\n", $reportfile2;
print FILE $reportcont2;
close (FILE);

my $ua = $n->{_ua};
foreach my $format ("nbe.xsl") {
	my $url = sprintf "https://%s:%s/file/xslt/?report=%s&xslt=%s&token=%s", $nessus_host, $port, $scanid, $format, $n->{_token};
	my $response = $ua->get($url);
	
	my $report;
	if ($response->as_string =~ /fileName=(.*)?"/) {
		my $report_id = $1;
		my $report_url = sprintf "https://%s:%s/file/xslt/download/?fileName=%s&step=2", $nessus_host, $port, $report_id;
		my $gotit = 0;
		while (! $gotit) {
			sleep 1;
			printf "[+] Downloading report form: %s\n", $report_url;
			$report = $ua->get($report_url);
			if ($report->as_string !~ /Refresh: \d+;.*download..fileName=/) {
				$gotit = 1;
			} else {
				sleep 1;
			}
		}
	}
	
	my $reportfilenbe = "$outfile.$format";
	open (FILE,">$reportfilenbe") or die "Cannot open file $reportfilenbe: $!";
	printf "[+] Saving $format format to: %s\n", $reportfilenbe;
	print FILE $report->content;
	close (FILE);
}

my $url = sprintf "https://%s:%s/report/format/generate", $nessus_host, $port;
print "[+] Requesting HTML report: $url\n";
my $post = [
	report => $scanid,
	format => "nchapter.html",
	chapters => "vuln_by_plugin",
	json => 1,
	token => $n->{_token},
];
my $response = $ua->post($url, $post);
my $report_id;
if ($response->as_string =~ /"file":"(.*?)"/) {
	$report_id = $1;
	print "[+] Got file ID: $report_id\n";
} else {
	print "ERROR:\n";
	print $response->as_string;
	exit 1;
}

my $report_url = sprintf "https://%s:%s/report/format/download?file=%s&token=%s", $nessus_host, $port, $report_id, $n->{_token};
my $gotit = 0;
while (! $gotit) {
	sleep 1;
	print "[+] Downloading HTML report: $report_url\n";
	my $report = $ua->get($report_url);
	if ($report->as_string =~ /Content-Disposition: attachment/) {
		$gotit = 1;
		my $reportfilenbe = "$outfile.html";
		open (FILE,">$reportfilenbe") or die "Cannot open file $reportfilenbe: $!";
		printf "[+] Saving HTML format to: %s\n", $reportfilenbe;
		print FILE $report->content;
		close (FILE);
	} else {
		print "[+] No report yet.  Polling...\n";
		print $report->as_string;
	}
}
			
