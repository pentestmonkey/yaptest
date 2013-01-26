#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use yaptest;
use File::Basename;
use File::Temp qw(tempfile);

my $script_name = basename($0);
my $usage = "Usage: $script_name domain user pass
Runs keimpx IPs in database with ports 139 or 445/TCP open.

NB: keimpx.py is required to be in the path.
";

my $domain = shift or die $usage;
my $username = shift or die $usage;
my $password = shift or die $usage;
my $y = yaptest->new();

my ($usersfh, $usersfile) = tempfile(CLEANUP => 1);
my ($pswpolicyfh, $pswpolicyfile) = tempfile(CLEANUP => 1);
my ($domainsfh, $domainsfile) = tempfile(CLEANUP => 1);
my ($sharesfh, $sharesfile) = tempfile(CLEANUP => 1);
print $usersfh "users\n";
print $pswpolicyfh "pswpolicy\n";
print $domainsfh "domains\n";
print $sharesfh "shares\n";

$y->run_test(
	command            => "keimpx.py -t ::IP:: -D \"$domain\" -U \"$username\" -P \"$password\" -x $usersfile < /dev/null",
	filter             => { port => [139, 445], transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'keimpx-users-::IP::.out',
	parser             => 'yaptest-parse-keimpx.pl'
);
$y->run_test(
	command            => "keimpx.py -t ::IP:: -D \"$domain\" -U \"$username\" -P \"$password\" -x $pswpolicyfile < /dev/null",
	filter             => { port => [139, 445], transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'keimpx-pswpolicy-::IP::.out',
	parser             => 'yaptest-parse-keimpx.pl'
);
$y->run_test(
	command            => "keimpx.py -t ::IP:: -D \"$domain\" -U \"$username\" -P \"$password\" -x $domainsfile < /dev/null",
	filter             => { port => [139, 445], transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'keimpx-domains-::IP::.out',
	parser             => 'yaptest-parse-keimpx.pl'
);
$y->run_test(
	command            => "keimpx.py -t ::IP:: -D \"$domain\" -U \"$username\" -P \"$password\" -x $sharesfile < /dev/null",
	filter             => { port => [139, 445], transport_protocol => 'tcp' },
	parallel_processes => 10,
	output_file        => 'keimpx-shares-::IP::.out',
	parser             => 'yaptest-parse-keimpx.pl'
);
