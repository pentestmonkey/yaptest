#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name ntp-10.0.0.1.out [ ntp-10.0.0.2.out ... ]
Reads output of ntpq and saves OS info port_info table.

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
my ($ip);

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";

	if ($file =~ /(\d+\.\d+\.\d+\.\d+)/) {
		$ip = $1;
	} else {
		print "ERROR: The name of file $file doesn't contain an IP and port.  Ignoring.\n";
		next;
	}

	unless (open (NTPFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	
	while (<NTPFILE>) {
		# print $_;
		chomp $_;
		my $line = $_;
		# system="SunOS"
		if ($line =~ /^system="([^"]+)"/) {
			my $os = $1;
			print "PARSED: IP=$ip, OS=$os\n";
			$y->insert_host_info(ip_address => $ip, key => "ntp_os", value => $os);
			$y->insert_issue(name => 'ntp_os_info', ip_address => $ip, port => 123, transport_protocol => "UDP");
		}
	}
	close NTPFILE;
}
$y->{dbh}->commit if $commit;

