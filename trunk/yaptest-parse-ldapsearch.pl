#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name ldapsearch-10.0.0.1-389.out [ ldapsearch-10.0.0.2-389.out ... ]
Reads output of \"ldapsearch ... namingContexts\" and saves
naming contexts to port_info table.

Options are:
	--help          Print this message
";

GetOptions (
	"help"      => \$help
);

die $usage if $help;
my $file = shift or die $usage;
my $y = yaptest->new();
my $commit = 1;
my ($port, $ip);

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";

	if ($file =~ /(\d+\.\d+\.\d+\.\d+)-(\d+)/) {
		$ip = $1;
		$port = $2;
	} else {
		print "ERROR: The name of file $file doesn't contain an IP and port.  Ignoring.\n";
		next;
	}

	unless (open (LDAPFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	
	while (<LDAPFILE>) {
		# print $_;
		chomp $_;
		my $line = $_;
		# namingContexts: dc=example,dc=com
		if ($line =~ /^namingContexts: (.*?)\s*$/) {
			my $nc = $1;
			print "PARSED: IP=$ip, PORT=$port, Naming Context=$nc\n";
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "ldap_namingcontext", port_info_value => $nc);
		}
		if ($line =~ /^defaultNamingContext: (.*?)\s*$/) {
			my $nc = $1;
			my $long_dom = $nc;
			$long_dom =~ s/DC=/./g;
			$long_dom =~ s/,//g;
			$long_dom =~ s/^\.//;
			print "PARSED: IP=$ip, Domain Name=$long_dom\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_long_dom", value => $long_dom);
		}
		if ($line =~ /^dnsHostName: (.*?)\s*$/) {
			my $hostname = $1;
			$y->insert_hostname(type => 'dns', ip_address => $ip, hostname => $hostname);
			$hostname =~ s/\..*//;
			$y->insert_hostname(type => 'windows_hostname', ip_address => $ip, hostname => $hostname);
		}
	}
	close LDAPFILE;
}
$y->{dbh}->commit if $commit;

