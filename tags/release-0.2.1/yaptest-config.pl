#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name query [ param-name ]
       $script_name set param-name param-value

Queries or changes the current yaptest configuration file.

The configuration filename is \$YAPTEST_CONFIG_FILE if set
or ~/.yaptestrc otherwise.

The variable \$YAPTEST_CONFIG_FILE holds the configuration
for the current test, while ~/.yaptestrc hold the default
configuration for future tests.

Examples:

View current settings:
\$ $script_name query

View a particular setting:
\$ $script_name query yaptest_interface

Change a setting:
\$ $script_name set yaptest_interface ath0
";

my $command = shift or die $usage;
my $y = yaptest->new();

# Print name of config file
print "Current config file: " . $y->get_config('yaptest_config_file') . "\n\n";

# Retreive settings
if ($command eq "query") {
	my $key = shift;
	die $usage if shift;

	if (defined($key)) {
		print "$key => " . (defined($y->get_config($key)) ? $y->get_config($key) : "") . "\n";
	} else {
		$y->dump_config();
	}

# Add / Modify settings
} elsif ($command eq "set") {
	my $key = shift or die $usage;
	my $value = shift or die $usage;
	die $usage if shift;
	print "Setting: $key => $value\n";
	$y->set_config($key, $value);
	$y->write_config();

} else {
	print "ERROR: Invalid command\n";
	die $usage;
}
