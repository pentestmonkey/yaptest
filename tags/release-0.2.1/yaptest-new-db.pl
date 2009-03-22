#!/usr/bin/env perl 
use strict;
use warnings;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name dbname yaptest.conf
Creates a new database named dbname.

Recommended usage is:

\$ mkdir mytest-dir; cd mytest-dir
\$ $script_name abc_co yaptest.conf
\$ source env.sh

yaptest.conf will be created in the current directory.
This will include database connection information and you'll
need this file everytime you run a yaptest script.

A second file env.sh will also be created.  It contains the
location of configuration file:

\$ cat yaptest.conf
YAPTEST_CONFIG_FILE=/home/u/mytest-dir/yaptest.conf; export YAPTEST_CONFIG_FILE

You need to source this file so that the other yaptest
script know where the config is kept.

\$ source yaptest.conf; # or
\$ . yaptest.conf

Troubleshooting:

- Ensure postgres is started: /etc/init.d/postgres start
- Ensure you installed the yaptest datbase:
    # cd src/yaptest-x.x.x/
    # make database
- Ensure your ~/.yaptestrc file contains details for your
  postgres server.  It is created the first time you run
  yaptest.
";

my $dbname = shift or die $usage;
my $config_file = shift or die $usage;
die $usage if shift;
my $y = yaptest->new($dbname, $config_file);
