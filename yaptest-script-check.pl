#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;

#
# To be called from within yaptest scripts
# It take an argument of programs, and check if they are there
#
# Example: code
#
# do "yaptest-script-check.pl";
# &check_programs("nmap");
#
# Multiple programs can be checked by:
# &check_programs("program1", "program2"); 
#
sub check_programs
{

my $check;

GetOptions (
        "check" => \$check,
);

	if($check)
	{

		while(my $program = shift)
		{
			my $output = `which $program 2>&1`;
			if($output =~ m/^which:/)
			{
				print "Missing: $program\n";
			}
			else
			{
				print "OK: $program\n";
			}
		}

		exit 1;
	}
}
