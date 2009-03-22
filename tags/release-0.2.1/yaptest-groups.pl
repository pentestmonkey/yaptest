#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Temp qw/ tempdir /;
use File::Basename;

my $username;
my $ip;
my $port;
my $file;
my $uid;
my $password;
my $trans;
my $group;
my $test_area;
my $debug = 1;
my $script_name = basename($0);
my $usage = "Usage: 
      $script_name add --group_ip ip [ --port n --trans (udp|tcp) ] --username name --group name
      $script_name add --group_ip ip [ --port n --trans (udp|tcp) ] -f file
      $script_name query [ options ]

Adds or queries usernames, passwords and password hashes.

options for \"query\" commands are:
        --group_ip    ip        IP group of interest resides on
	--member_name name      Name of group member
	--uid         n         UID for account
	--group_name  name      Group name of interest
	--password    pass      Password
	--test_area   area      Test area (vlan1, vlan2, etc.)

When run in \"add\" mode this script can read /etc/group files.  Support for reading
enum4linux files will follow.

Tip: Import /etc/passwd using yaptest-credentials.pl before importing groups from /etc/group.

";

GetOptions (
	"port=s"        => \$port,
	"uid=s"         => \$uid,
	"password=s"    => \$password,
	"group_ip=s"    => \$ip,
	"member_name=s" => \$username,
	"group_name=s"  => \$group,
	"file=s"        => \$file,
	"trans=s"       => \$trans,
	"test_area=s"   => \$test_area
);

my $command = shift or die $usage;

if ($command ne "add" and $command ne "query") {	
	print "ERROR: Unknown command\n";
	print $usage;
	exit(1);
}

if (defined($trans)) {
	$trans = uc $trans;
}

my $y = yaptest->new();

if ($command eq "add") {
	my %port_opts = ();

	unless (defined($ip)) {
		print "ERROR: \"-i ip_address\" option is mandatory for \"add\" command\n";
		exit 1;
	}

	# Lookup windows hostname
	my $hostname = $y->get_hostname($ip, "windows_hostname");
	print "HOSTNAME: $hostname\n" if defined($hostname);

	if (defined($port)) {
		if (!defined($trans) or uc($trans) ne "TCP" and uc($trans) ne "UDP") {
			print "ERROR: \"--trans tcp\" or \"--trans udp\" argument is mandatory when \"--port n\" is used\n";
			exit 1;
		}

		$trans = uc($trans);
		%port_opts = ( port => $port, transport_protocol => $trans );
	}

	# Creds specified from command line
	if (!defined($file)) {
		unless (defined($username)) {
			print "ERROR: \"--username username\" option is mandatory for \"add\" command\n";
			exit 1;
		}

		$y->add_group_membership(ip_address => $ip, %port_opts, uid => $uid, username => $username, group_name => $group);

		print "Group membership added successfully\n";

	# Read in password file
	} else {

		open (FILE, "<$file") or die "ERROR: Can't open file $file for reading: $!\n";
		
		my $current_group = "";
		my $current_rid = "";
		while (<FILE>) {
			print;
			chomp;
			my $line = $_;
			$line =~ s/\x0D//g;
		
			# Unix group file
			if ( $line =~ /^(\w+):x?:(\d+):([^:]*)$/) {
				my $group_name = $1;
				my $gid = $2;
				my $member_string = $3;
				my @members;
				print "PARSED: IP=$ip, GROUP=$group_name, GID=$gid, MEMBERSTRING=$member_string\n";
				if (defined($member_string)) {
					@members = split(",", $member_string);
				}
		
				$y->add_group(ip_address => $ip, credential_type_name => "os_unix", group_name => $group_name, gid => $gid, %port_opts);
				foreach my $member (@members) {
					$y->add_group_membership(group  => { ip_address => $ip, group_name => $group_name, gid => $gid, credential_type_name => "os_unix" }, 
					                         member => { ip_address => $ip, username => $member });
				}
			}

			# Enum4linux file - doesn't work yet
			if ($line =~ /^group:\[([^\]]+)\] rid:\[0x([0-9a-fA-F]+)\]/) {
				my $group = $1;
				my $gid = hex($2);
				print "PARSED: group=$group, gid=$gid\n" if $debug;
				$y->add_group(ip_address => $ip, credential_type_name => "os_windows", group_name => $group, gid => $gid, %port_opts);
			}

			if ($line =~ /Group\s+'(.*)'\s+\(RID:\s+(\d+)\)\s+has\s+members:/) {
				$current_group = $1;
				$current_rid = $2;
				print "PARSED: group=$current_group\n" if $debug;
				$y->add_group(ip_address => $ip, credential_type_name => "os_windows", group_name => $current_group, gid => $current_rid, %port_opts);
			} elsif (defined($current_group) and $line =~ /^\s+(\S+)\\(.+)$/) {
				my $host_dom = $1;
				my $member = $2;
				$member =~ s/\x0d//g;
				print "PARSED: member=$member\n" if $debug;

				# if member is a local entity...
				if ( $host_dom eq $hostname or $host_dom eq "NT AUTHORITY") {
					print "member is a local entity...\n";
					$y->add_group_membership(group  => { ip_address => $ip, group_name => $current_group, gid => $current_rid, credential_type_name => "os_windows" }, 
					                         member => { ip_address => $ip, username => $member });
				# if member is a domain group
				} elsif (@{$y->get_host_info(key => "windows_dc", value => $host_dom)}) {
					print "member is a domain group...\n";
					$y->add_group_membership(group  => { ip_address => $ip, group_name => $current_group, gid => $current_rid, credential_type_name => "os_windows" }, 
					                         member => { domain => $host_dom, username => $member });
				} else {
					print "WARNING: Need to add member $host_dom\\$member to group $current_group, but don't understand what member is.  Skipping.\n";
				}
			} else {
				undef $current_group;
				undef $current_rid;
			}
		}
	}
	$y->commit;
}

if ($command eq "query") {
	$y->print_table($y->get_groups(group_ip => $ip, member_name => $username, group_name => $group));
}

$y->destroy;
