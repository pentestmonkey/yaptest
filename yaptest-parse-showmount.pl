#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name showmount-e-10.0.0.1.out [ showmount-e-10.0.0.2.out ... ]
Reads output of \"showmount -e IP\" and saves exports to port_info table.

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
my $port = 2049;
my ($ip);

unshift @ARGV, $file;

while ($file = shift) {
	print "Processing $file...\n";

	if ($file =~ /showmount-e-(\d+\.\d+\.\d+\.\d+)/) {
		$ip = $1;
	} else {
		print "ERROR: The name of file $file doesn't contain an IP and port.  Ignoring.\n";
		next;
	}

	unless (open (SHOWMOUNTFILE, "<$file")) {
		print "ERROR: Can't open $file for reading.  Ignoring.\n";
		next;
	}
	
	while (<SHOWMOUNTFILE>) {
		# print $_;
		chomp $_;
		my $line = $_;
		# namingContexts: dc=example,dc=com
		if ($line =~ /^(\/\S+)/) {
			my $export = $1;
			print "PARSED: IP=$ip, PORT=$port, Export=$export\n";
			$y->insert_port_info(ip => $ip, port => $port, transport_protocol => 'TCP', port_info_key => "nfs_export", port_info_value => $export);
		}
	}
	close SHOWMOUNTFILE;
}
$y->{dbh}->commit if $commit;

