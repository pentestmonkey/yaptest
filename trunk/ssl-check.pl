#!/usr/bin/perl -w
use strict;
use Expect;

my $usage = "$0 ip port

Makes an SSL connection to target, then tries to renegotiate.  Assumes HTTP protocol
to avoid false positives.

Grep this output for these strings to indicate the presence of security issues:
* 'Insecure Renegotiaion is possible for IP:PORT': CVE-2011-1473 + CVE-2009-3555
* 'Secure Renegotiaion is possible for IP:PORT'    CVE-2011-1473

CVE-2009-3555: TLS Authentication Gap (MiTM)
CVE-2011-1473: Server-side CPU Exhaustion (DoS Attack)

The 'openssl' program is required to be in your path.
\n";
my $target = shift or die $usage;
my $port  = shift or die $usage;
my $timeout = 10;

my $command = "openssl s_client -connect $target:$port";
print "[+] Spawning command: $command\n";
my $exp = new Expect;
$exp->spawn($command) or die "Cannot spawn command: $command\n";
$exp->log_stdout(1); # set to 0 for cleaner output
$exp->exp_internal(0);

my $type = "";
my $ret;		

print "[+] Getting certification information\n";
system("openssl s_client -connect $target:$port | sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' | openssl x509 -text");

$ret = $exp->expect($timeout, "Secure Renegotiation IS NOT supported", "Secure Renegotiation IS supported", "connect:errno=", ":error:");
if (defined($ret) and $ret == 0) {
	print "[+] Timemout waiting for SSL connection.  Quitting.\n";
	exit 1;
}
if (defined($ret) and $ret == 1) {
	print "[+] Secure Renegotiation is not supported by $target:$port\n";
	$type = "Insecure";
}
if (defined($ret) and $ret == 2) {
	print "[+] Secure Renegotiation is supported by $target:$port\n";
	$type = "Secure";
}
if (defined($ret) and ($ret == 3 or $ret == 4)) {
	print "[+] Error connecting to $target:$port\n";
	exit 1;
}

$ret = $exp->expect($timeout, "\n---");
if (defined($ret) and $ret == 0) {
	print "[+] Timemout waiting for SSL connection.  Quitting.\n";
	exit 1;
}
if (defined($ret) and $ret == 1) {
	print "[+] SSL connection established to $target:$port\n";
	print "[+] Sending GET Requst part #1\n";
	$exp->send("GET / HTTP/1.0\r\n");
	print "[+] Attempting Renegotiation\n";
	$exp->send("R\r\n");
	my $result = $exp->expect($timeout, "verify return:", ":error:");
	if (defined($result) and $result == 0) {
		print "[+] Timeout waiting for renegotiaion with $target:$port\n";
		exit 1;
	}
	if (defined($result) and $result == 1) {
		print "\n[+] $type Renegotiation seems to be successful for $target:$port\n";
		$exp->send("\r\n");
		my $result2 = $exp->expect($timeout, "HTTP");
		if (defined($result) and $result == 1) {
			print "\n[+] $type Renegotiation is possible for $target:$port\n";
			exit 1;
		}
		print "\n[+] $type Renegotiation went wrong for $target:$port.  Investigate manually.\n";
		exit 1;
	}
	if (defined($result) and $result == 2) {
		print "[+] $type Renegotiaion failed for $target:$port\n";
		exit 1;
	}
	print "\n[+] $type Renegotiation went wrong for $target:$port.  Investigate manually.\n";
}
$exp->hard_close;
