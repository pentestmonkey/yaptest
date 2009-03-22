#!/usr/bin/env perl
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name
Uses \"ldapsearch ... -s base\" on each port identified by nmap as running LDAP.
This query can often be used to find out the base DN.  Once this is
known the following command will list the directory:

ldapsearch -h host -p port -b 'o=the base DN you found' -s sub

NB: ldapsearch has to be in the path.  Doesn't work for LDAP-over-SSL.
";

die $usage if shift;

my $y = yaptest->new();

$y->run_test(
	command     => 'ldapsearch -x -h ::IP:: -p ::PORT:: -s base namingContexts',
	output_file => 'ldapsearch-namingcontexts-::IP::-::PORT::.out',
	filter      => { port_info => "nmap_service_name = ldap", ssl => 0 },
	parser      => "yaptest-parse-ldapsearch.pl"
);

$y->run_test(
	command     => 'ldapsearch -x -h ::IP:: -p ::PORT:: -s base',
	filter      => { port_info => "nmap_service_name = ldap", ssl => 0 },
	parser      => "yaptest-parse-ldapsearch.pl",
);

$y->run_test(
	command     => 'ldapsearch -x -h ::IP:: -p ::PORT:: -b "::PORTINFO-ldap_namingcontext::" -s sub',
	output_file => 'ldapsearch-namingcontext-::IP::-::PORT::.out',
	filter      => { ssl => 0 },
	parser      => "yaptest-parse-ldapsearch.pl"
);

# If null baseDN are allow, the following downloads the whole
# directory:
#
# ldapsearch -h 10.0.0.1 -p 389 -s sub
