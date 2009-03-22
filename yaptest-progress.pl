#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use Getopt::Long;
use Data::Dumper;
use File::Basename;

my $y = yaptest->new;
my $file;
my $test_area;
my @ips;
my @ports;
my $script_name = basename($0);
my $usage = "Usage: 
    $script_name list
    $script_name reset command_id [ command_id ... ] [ -i ip ]

Lists the commands that have been run by yaptest along with the
command_id of each.

Removes commands from yaptest's internal progress table.  This
makes yaptest 'forget' that it's run certain commands so that they
can be run again.

Why is this useful?

By default yaptest remembers all the commands it has run and the
hosts / ports that it has run them against (e.g. it might 
remember that it's run nikto against 10.0.0.1:8080).  If you
try to run a script twice (e.g. yaptest-nikto.pl) yaptest will 
exclude any hosts that it's already scanned.

This is normally a good thing, but what if nikto failed for
some reason (e.g. your IP stack wasn't configured)?

In this case you'd need to reset yaptest's internal progress
table for the nikto scan so it forgot it had run the nikto
scan.

To list the commands that have been run:
  \$ yaptest-progress.pl list
  command_id    command_template
  port_18       nikto.pl -h ::IP:: -p ::PORT::
  ...

Use the command_id to reset entries from yaptest's progress table.
You might want to reset all entries, or just for some IPs:

  \$ yaptest-progress.pl reset port_18
  \$ yaptest-progress.pl reset port_18 -i 10.0.0.1
  \$ yaptest-progress.pl reset port_18 -p 8080
  \$ yaptest-progress.pl reset port_18 -i 10.0.0.1 -p 8080
";

GetOptions (
	"file=s" => \$file,
	"test_area=s" => \$test_area,
	"ip=s" => \@ips,
	"port=s" => \@ports,
);

my $command = shift or die $usage;

if ($command eq "list") {
	die $usage unless (scalar(@ips) != 1);
	my $aref = $y->get_command_list();
	$y->print_table_hashes($aref, undef, qw(command_id command_template));
} elsif ($command eq "reset") {
	my $command_id = shift or die $usage;
	$y->reset_progress($command_id, ip_address => \@ips, port => \@ports, test_area => $test_area);
	print "Progress successfully reset for command_id $command_id\n";
	while ($command_id = shift) {
		$y->reset_progress($command_id, ip_address => \@ips, port => \@ports, test_area => $test_area);
		print "Progress successfully reset for command_id $command_id\n";
	}
} else {
	die $usage;
}
$y->{dbh}->commit;
