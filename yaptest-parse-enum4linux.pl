#!/usr/bin/env perl
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;
use Data::Dumper;

my $script_name = basename($0);
my $usage = "Usage: $script_name enum4linux-10.0.0.1.out [ enum4linux-10.0.0.2.out ]

Parses enum4linux output for Windows usernames, OS information.  IP must be in the filename.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my %dc_for;
my $y = yaptest->new();

while (my $filename = shift) {
	print "Processing $filename ...\n";

	unless ($filename =~ /(\d+\.\d+\.\d+\.\d+)/) {
		print "WARNING: Filename $filename doesn't contain an IP address.  Skipping...\n";
		next;
	}


	my $ip = $1;
	print "IP: $ip\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;

		# HOSTNAME          <00>             UNIQUE
		if ($line =~ /^\s*([a-zA-Z0-9_-]+)[\s\x08]+<00>\s+-\s+\S\s+<ACTIVE>/) {
			my $hostname = $1;
			print "PARSED: IP=$ip, HOST=$hostname\n";

			$y->insert_port(ip => $ip, port => 137, transport_protocol => 'UDP');
			$y->insert_hostname(type => 'windows_hostname', ip_address => $ip, hostname => $hostname);
			$y->insert_issue(name => 'nbt_info', ip_address => $ip, port => 137, transport_protocol => 'UDP');
		}

		# MYDOMAIN          <00>              GROUP
		if ($line =~ /^\s*([a-zA-Z0-9 _-]+?)[\s\x08]+<00>\s+-\s+<GROUP>\s+\S\s+<ACTIVE>/) {
			my $domain = $1;
			print "PARSED: IP=$ip, DOMAIN=$domain\n";

			$y->insert_host_info(ip_address => $ip, key => "windows_domwkg", value => $domain);
		}

		# MYDOMAIN          <1c>              GROUP
		if ($line =~ /^\s*([a-zA-Z0-9_-]+)[\s\x08]+<1[cC]>\s+-\s+<GROUP>\s+\S\s+<ACTIVE>/) {
			my $domain = $1;
			print "PARSED: IP=$ip, DOMAIN=$domain\n";

			$y->insert_host_info(ip_address => $ip, key => "windows_dc", value => $domain);
			$y->insert_host_info(ip_address => $ip, key => "windows_member_of", value => "DOMAIN");
		}

                if ($line =~ /^\s*MAC Address =\s+((?:[a-fA-F0-9]{2}-){5}[a-fA-F0-9]{2})/) {
                        my $mac = $1;
			unless ($mac eq '00-00-00-00-00-00') {
	                        print "PARSED: IP=$ip, MAC=$mac\n";
	                        $y->insert_ip_and_mac($ip, $mac);
			}
                }

		# Parse OS info
		if ($line =~ /Got OS info for (\d+\.\d+\.\d+\.\d+) from smbclient: Domain=\[([^]]+)\] OS=\[([^]]+)\] Server=\[([^]]+)\]/) {
			my $ip = $1;
			my $domain = $2;
			my $os = $3;
			my $smb_server = $4;
			$y->insert_host_info(ip_address => $ip, key => "os", value => $os);
			$y->insert_host_info(ip_address => $ip, key => "windows_domwkg", value => $domain);
			$y->insert_host_info(ip_address => $ip, key => "smb_server", value => $smb_server);
			$y->insert_issue(ip_address => $ip, name => "smb_os_info");
		}
		
		# Password policy
		if ($line =~ /Account Lockout Threshold: (\S+)/) {
			my $threshold = $1;
			print "PARSED: Host $ip has lockout threshold: $threshold\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_acct_lockout_threshold", value => $threshold);
		}
		if ($line =~ /Minimum password length: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Minimum password length: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_min_password_len", value => $value);
		}
		if ($line =~ /Password history length: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Password history length: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_password_hist_len", value => $value);
		}
		if ($line =~ /Maximum password age: ([\S ]+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Maximum password age: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_max_password_age", value => $value);
		}
		if ($line =~ /Password Complexity Flags: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has /Password Complexity Flags: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_password_complexity", value => $value);
		}
		if ($line =~ /Reset Account Lockout Counter: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has /Reset Account Lockout Counter: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_reset_acct_lockout_ctr", value => $value);
		}
		if ($line =~ /Locked Account Duration: (\S+)/) {
			my $value = $1;
			print "PARSED: Host $ip has Locked Account Duration: $value\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_acct_lockout_duration", value => $value);
		}

		# Domain or workgroup?
		if ($line =~ /Host is part of a workgroup .not a domain./) {
			print "PARSED: Host $ip is in a WORKGROUP\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_member_of", value => 'WORKGROUP');
		}

		if ($line =~ /Host is part of a domain .not a workgroup./) {
			print "PARSED: Host $ip is in a DOMAIN\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_member_of", value => 'DOMAIN');
		}

		# Domain SID
		if ($line =~ /Domain Sid: (S-[0-9-]+)/) {
			my $sid = $1;
			print "PARSED: Domain SID for $ip: $sid\n";
			$y->insert_host_info(ip_address => $ip, key => "windows_domain_sid", value => $sid);
		}

		# Share bruteforce issue
		if ($line =~ /^ipc\$ EXISTS/i) {
			$y->insert_issue(ip_address => $ip, name => "smb_share_enum");
		}

		# Null sessions issue
		if ($line =~ /Server (\d+\.\d+\.\d+\.\d+) allows sessions using username '', password ''/) {
			my $ip = $1;
			$y->insert_issue(ip_address => $ip, name => "smb_null_session");
		}

		if ($line =~ /^group:\[([^\]]+)\] rid:\[0x([0-9a-fA-F]+)\]/) {
			my $group = $1;
			my $gid = hex($2);
			print "PARSED: ip=$ip, group=$group, gid=$gid\n";
			$y->add_group(ip_address => $ip, credential_type_name => "os_windows", group_name => $group, gid => $gid);
		}

		# Group 'Administrators' (RID: 544) has member: SOMEHOST\bob
		if ($line =~ /^Group '([^']+)' \(RID: (\d+)\) has member: ([^\\]+)\\([\S ]+)/) {
			my $group_name = $1;
			my $gid = $2;
			my $member_hostname = $3;
			my $member = $4;
			print "PARSED: IP=$ip, GROUP=$group_name, GID=$gid, MEMBERSTRING=$member_hostname\\$member\n";
			$y->add_group(ip_address => $ip, credential_type_name => "os_windows", group_name => $group_name, gid => $gid);
			my $hostname = $y->get_hostname($ip, "windows_hostname");

			# if member is a local entity...
			if ( $member_hostname eq $hostname or $member_hostname eq "BUILTIN") {
				print "DEBUG: member is a local entity...\n";
				$y->add_group_membership(group  => { ip_address => $ip, group_name => $group_name, gid => $gid, credential_type_name => "os_windows" },
							 member => { ip_address => $ip, username => $member });
			} elsif ($member_hostname eq "NT AUTHORITY") {
				print "DEBUG: member is a local entity...\n";
				$y->add_group(ip_address => $ip, credential_type_name => "os_windows", group_name => "$member_hostname\\$member");
				$y->add_group_membership(group  => { ip_address => $ip, group_name => $group_name, gid => $gid, credential_type_name => "os_windows" },
							 member => { ip_address => $ip, username => "$member_hostname\\$member" });
			# if member is a domain user/group
			} elsif (@{$y->get_host_info(key => "windows_dc", value => $member_hostname)}) {
				print "WARNING: member is a domain group/user.  Not implemented yet...\n";
				# $y->add_group_membership(group  => { ip_address => $ip, group_name => $current_group, gid => $current_rid, credential_type_name => "os_windows" },
				#                          member => { domain => $host_dom, username => $member });
			} else {
				print "WARNING: Need to add member $member_hostname\\$member to group $group_name, but don't understand what member is.  Skipping.\n";
			}
		}

		# RA=1
		# S-1-5-21- ... Administrator (1)
		# S-1-5-21- ... Administrator (Local User)
		if ($line =~ /^S-1-5-21-[\d-]+-(\d+)\s+[^\\]+\\(.*) \((?:1|Local User)/) {
			my $uid = $1;
			my $username = $2;
			print "PARSED: USER=$username, UID=$uid\n";

			$y->insert_credential(ip_address => $ip, uid => $uid, username => $username, credential_type_name => "os_windows");
			$y->insert_issue(ip_address => $ip, name => "win_rid_cycle");

		# RA=0
		# index: 0x2 RID: 0x1f5 acb: 0x211 Account: Guest Name:   Desc: Built-in account for guest access to the computer/domain
		} elsif ($line =~ /^index:\s+0x[0-9a-fA-F]+\s+RID:\s+0x([0-9a-fA-F]+)\s+acb:\s+0x[0-9a-fA-F]+\s+Account:\s+(.*?)\s+Name:\s+.*?\s+Desc:\s+.*/) {
			my $uid = hex($1);
			my $username = $2;
			print "PARSED: USER=$username, UID=$uid\n";

			$y->insert_issue(ip_address => $ip, name => "win_user_list");
			$y->insert_credential(ip_address => $ip, uid => $uid, username => $username, credential_type_name => "os_windows");
		}
	}
}
$y->commit;
$y->destroy;

