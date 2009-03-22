#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use Data::Dumper;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Performs SNMP MIB walking on all hosts for which the database knows community strings.

NB: snmpwalk is required to be in the path.
";

die $usage if shift;

my @miblist = (
	{ mib => "1.3.6.1.2.1.1.1",           label => "system-desc" },
	{ mib => "1.3.6.1.2.1.2.1.0",         label => "nic-count" },
	{ mib => "ipAdEntAddr",               label => "interface-ips" },
	{ mib => "enterprises.42.3.12.1.1.8", label => "unix-process-owners" },
	{ mib => "1.3.6.1.4.1.77.1.2.25.1.1", label => "win-usernames" },
	{ mib => "1.3.6.1.4.1.77.1.2.27.1.1", label => "win-lanman-shares" },
	{ mib => "1.3.6.1.2.1.25.4.2.1.2",    label => "service-progs" },
	{ mib => "1.3.6.1.4.1.77.1.2.3.1.1",  label => "win-service-names" },
	{ mib => "1.3.6.1.2.1.25.6.3.1.2",    label => "installed-software" },
	{ mib => "enterprises",               label => "enterprises" },
	{ mib => ".",                         label => "all" }
);

# Read IP list from database, write to tmp file
my $y = yaptest->new();
my $aref = $y->get_credentials(credential_type_name => "snmp_community");

foreach my $mib_href (@miblist) {
	my $mib   = $mib_href->{mib};
	my $label = $mib_href->{label};
	foreach my $row_href (@$aref) {
		my $ip = $row_href->{ip_address};
		my $port = $row_href->{port};
		my $tp = $row_href->{transport_protocol_name};
		my $community = $row_href->{password};
		if ($tp ne "UDP") {
			print "WARNING: Only UDP is supported.  Ignoring.\n";
			next;
		}
		if ($port != 161) {
			print "WARNING: Only port 161 is supported.  Ignoring.\n";
			next;
		}
		next unless (defined($community));
		my %parser = ();
		%parser = (parser => "yaptest-parse-snmpwalk.pl") if ($label eq "win-usernames");
		%parser = (parser => "yaptest-parse-snmpwalk.pl") if ($label eq "unix-process-owners");
		$y->run_command_save_output(
			"snmpwalk -Os -v 1 -c '$community' $ip $mib",
			"snmpwalk-$ip-$community-$label.out",
			max_lines          => 20000,
			parallel_processes => 25,
			inactivity_timeout => 10,
			%parser
		);
	}
}

$y->destroy;
