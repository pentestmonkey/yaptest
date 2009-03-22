#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Getopt::Long;
use File::Basename;

my $script_name = basename($0);
my $help = 0;
my $usage = "Usage: $script_name [options]
Prints out a comma separated list of all open ports found so far (TCP and UDP).  Useful for pasting into nessus.

Options are:
	--help          Print this message

";

GetOptions (
	"help"      => \$help
);

die $usage if $help;
die $usage if shift;

my %ports;
my $y = yaptest->new();

my $hosts_ports_tcp_href = $y->get_all_open_ports_tcp();
my $hosts_ports_udp_href = $y->get_all_open_ports_udp();
$y->destroy;
my $processes = 0;

foreach my $host (keys %{$hosts_ports_tcp_href}) {
	map { $ports{$_} = 1 } @{$hosts_ports_tcp_href->{$host}};
}

foreach my $host (keys %{$hosts_ports_udp_href}) {
	map { $ports{$_} = 1 } @{$hosts_ports_udp_href->{$host}};
}

print join(",", sort { $a <=> $b } keys(%ports)) . "\n";
