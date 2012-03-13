#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name web_check.out [web_check.out.2 ... ]
Parse the output from web-check.pl and enter it into the database.
";

my $have_arg = shift or die $usage;
unshift @ARGV, $have_arg;
my $verbose = 1;

while (my $file = shift) {
	print "Processing $file...\n";

	# Check we can open file
	unless (open (FILE, "<$file")) {
		warn "WARNING: Can't open file $file for reading.  Ignoring.  Error was: $!\n";
		next;
	}

	while (<FILE>) {
		chomp;
		my $line = $_;
		print "$line\n" if $verbose;
		yaptest::parse::web_check($line);
	}

	close(FILE);
}

package yaptest::parse;

use yaptest;
use MIME::Base64 qw(encode_base64 decode_base64);

sub web_check {
	my $line = shift;
	my $commit = 1;

	my $connection = yaptest->new;

	# [I]	https://1.2.3.4:443/	http_x_powered_by	PHP/5.3.3-7+squeeze3
	if ($line =~ /^\[I\]\s+http[s]:\/\/([\d\.]+):(\d+)\/\S*\s+(\S+)\s+(.*?)\s+/) {
		my $ip    = $1;
		my $port  = $2;
		my $key   = $3;
		my $value = $4;

		if ($key =~ /_b64$/) {
			$key =~ s/_b64$//;
			$value = decode_base64($value);
		}

		my $value_oneline = $value;
		$value_oneline =~ s/\r/\\r/g;
		$value_oneline =~ s/\n/\\n/g;
		
		print "PARSED: IP=$ip, PORT=$port, KEY=$key, VALUE=$value_oneline\n";
		$connection->insert_port(ip => $ip, transport_protocol => "tcp", port => $port);
                $connection->insert_port_info(
                          ip                 => $ip,
                          port               => $port,
                          transport_protocol => "TCP",
                          port_info_key      => $key,
                          port_info_value    => $value
                );
		$connection->commit if $commit;
	}
}
