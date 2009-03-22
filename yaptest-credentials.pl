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
my $hash;
my $credtype;
my $hashtype;
my $trans;
my $test_area;
my $script_name = basename($0);
my $usage = "Usage: 
      $script_name add --ip ip -f passwd.txt
      $script_name add --ip ip --credtype type [ options ]
      $script_name query [ options ]
      $script_name crack { lanman | des }
      $script_name rcrack table-dir { lanman | ntlm }
      $script_name stats 

Adds or queries usernames, passwords and password hashes.

options for \"add\" and \"query\" commands are:
	--port      n         Port to which credential correspond
	--trans     prot      Transport protocol (tcp or udp)
	--uid       n         UID for account
	--username  user      Username
	--password  pass      Password
	--hash      hash      Password hash
	--file      file      passwd, shadow or pwdump file
	--credtype  credtype  Credential type (os_unix, os_windows, etc.)
	--hashtype  hashtype  Type of hash (lanman, blowfish, etc.)
	--test_area area      Test area (vlan1, vlan2, etc. or 'all')

If you want to run a copy of John that's not in your path or run the MPI 
version under mpiexec specify a different command line for john like this:
\$ yaptest-config.pl query yaptest_john_command
\$ yaptest-config.pl set yaptest_john_command 'mpiexec -n 4 /path/to/john'

You might also need to change the location of John's pot file like this:
\$ yaptest-config.pl query yaptest_john_pot
\$ yaptest-config.pl set yaptest_john_pot /path/to/john.pot

";

GetOptions (
	"port=s"     => \$port,
	"uid=s"      => \$uid,
	"password=s" => \$password,
	"hash=s"     => \$hash,
	"credtype=s" => \$credtype,
	"hashtype=s" => \$hashtype,
	"ip=s"       => \$ip,
	"username=s" => \$username,
	"file=s"     => \$file,
	"trans=s"    => \$trans,
	"test_area=s" => \$test_area
);

my $command = shift or die $usage;

if ($command ne "add" and $command ne "query" and $command ne "crack" and $command ne "rcrack" and $command ne "stats") {	
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

	# Creds specified from command line
	if (!defined($file)) {
		if (defined($port)) {
			if (!defined($trans) or uc($trans) ne "TCP" and uc($trans) ne "UDP") {
				print "ERROR: \"--trans tcp\" or \"--trans udp\" argument is mandatory when \"--port n\" is used\n";
				exit 1;
			}
	
			$trans = uc($trans);
			%port_opts = ( port => $port, transport_protocol => $trans );
		}

		$y->insert_credential(ip_address => $ip, %port_opts, uid => $uid, username => $username, password => $password, password_hash => $hash, password_hash_type => $hashtype, credential_type_name => $credtype);

		print "Credentials added successfully\n";

	# Read in password file
	} else {

		open (FILE, "<$file") or die "ERROR: Can't open file $file for reading: $!\n";
		
		while (<FILE>) {
			print;
			chomp;
			my $line = $_;
		
			# TODO: Issue for hashes in /etc/passwd (should use shadow)

			# Remove password aging info from password field in /etc/passwd
			if ($line =~ /^([^:]+:[^:]*),(?:[^:]+)(:\d+:\d+:[^:]+:[^:]+:[^:]+.*)/) {
				$line = $1.$2;
			}

			# Unix shadow file with MD5-based hash
			if ( $line =~ /^([^:]+):(\$1\$[0-9A-Za-z\.\/]+\$[0-9A-Za-z\.\/]+):/) {
				my $username = $1;
				my $passwd_hash = $2;
		
				$y->insert_credential(ip_address => $ip, username => $username, password_hash => $passwd_hash, password_hash_type => "bsd_md5", credential_type_name => "os_unix");
			
			# Unix shadow file with blowfish-based hash
			} elsif ( $line =~ /^([^:]+):(\$2a\$04\$[0-9A-Za-z\.\/]+):/) {
				my $username = $1;
				my $passwd_hash = $2;
		
				$y->insert_credential(ip_address => $ip, username => $username, password_hash => $passwd_hash, password_hash_type => "blowfish", credential_type_name => "os_unix");
			
			# Windows pwdump style hash
			} elsif ( $line =~ /^([^:]+):(\d+):([0-9a-fA-F]{32}|NO PASSWORD\*+):([0-9a-fA-F]{32}|NO PASSWORD\*+):/) {
				my $username = $1;
				my $uid = $2;
				my $lanman_hash = uc($3);
				my $nt_hash = uc($4);
		
				if ($lanman_hash =~ /NO PASSWORD/) {
					$y->insert_credential(ip_address => $ip, username => $username, uid => $uid, password => "", password_hash_type => "lanman", credential_type_name => "os_windows");
				} else {
					$y->insert_credential(ip_address => $ip, username => $username, uid => $uid, password_hash => $lanman_hash, password_hash_type => "lanman", credential_type_name => "os_windows");
				}

				if ($nt_hash =~ /NO PASSWORD/) {
					$y->insert_credential(ip_address => $ip, username => $username, uid => $uid, password => "", password_hash_type => "nt", credential_type_name => "os_windows");
				} else {
					$y->insert_credential(ip_address => $ip, username => $username, uid => $uid, password_hash => $nt_hash, password_hash_type => "nt", credential_type_name => "os_windows");
				}

			# Unix shadow file with DES-based hash
			} elsif ($line =~ /^([^:]+):([0-9A-Za-z\.\/]{13}):.*:.*:.*:/) {
				my $username = $1;
				my $passwd_hash = $2;
		
				$y->insert_credential(ip_address => $ip, username => $username, password_hash => $passwd_hash, password_hash_type => "des", credential_type_name => "os_unix");
				$y->insert_issue(name => "unix_des_hashes", ip_address => $ip);
			
			# Unix passwd file with no hash
			} elsif ($line =~ /^([^:]+):x:(\d+):(\d+):/) {
				my $username = $1;
				my $uid = $2;
				my $gid = $3;
		
				$y->insert_credential(ip_address => $ip, username => $username, uid => $uid, credential_type_name => "os_unix");
		
			# Unix shadow file without a hash
			} elsif ($line =~ /^([^:]+):(?:NP|\*LK\*|!|\*):/) {
				my $username = $1;
		
				$y->insert_credential(ip_address => $ip, username => $username, credential_type_name => "os_unix");

			# Unix passwd file with cleartext passwords
			# user:password:232:20:My Name:/users/user:/usr/bin/ksh
			} elsif ($line =~ /^([^:]+):([^:]*):\d+:\d+:[^:]+:[^:]+:[^:]+/) {
				my $username = $1;
				my $password = $2;
		
				$y->insert_credential(ip_address => $ip, username => $username, password => $password, credential_type_name => "os_unix");
				$y->insert_issue(name => "unix_password_in_passwd", ip_address => $ip);
			}
			# TODO: Oracle "select name, password from sys.user$"
			#       read the john.pot file
			#       read the output of john
			#       read the output of rcrack
		}

		# Break LANMAN hash into two parts in backend db.  Ugly to have to
		# call this here, but performance suffers badly if it's called for
		# every insert.
		$y->update_half_hashes();
	}
	$y->commit;
}

if ($command eq "query") {
	my $aref = $y->get_credentials(ip_address => $ip, port => $port, transport_protocol => $trans, uid => $uid, username => $username, password => $password, password_hash => $hash, password_hash_type_name => $hashtype, credential_type_name => $credtype, test_area_name => $test_area);

	$y->print_table_hashes($aref, undef, qw(test_area_name credential_type_name domain ip_address port transport_protocol_name uid username password password_hash_type_name password_hash));
}

if ($command eq "crack") {
	my $hash_type = shift or die $usage;
	$hash_type = lc $hash_type;
	my $john_format;
	if ($hash_type eq 'ntlm' or $hash_type eq 'nt') {
		$hash_type = 'nt';
		$john_format = 'nt';
	}

	if ($hash_type eq 'lanman') {
		$hash_type = 'lanman';
		$john_format = 'lm';
	}

	my $dir = tempdir(".john-session-XXXXX", CLEANUP => 1);
	chdir $dir;
	my $john_command = $y->get_config('yaptest_john_command') || "john";
	my $john_pot = $y->get_config('yaptest_john_pot') || "john.pot";
	my $filename = $y->get_password_hash_file( password_hash_type_name => $hash_type );

	unless (defined($filename)) {
		print "No passwords of type $hash_type to crack.  Exiting.\n";
		exit 0;
	}
	
        $y->run_command_save_output(
                "cat $filename; $john_command --format=$john_format $filename",
                "john-$hash_type.out",
        );

	$y->parse_john_pot($john_pot);
	$y->parse_john_pot("john.pot");
	$y->parse_john_pot($ENV{"HOME"} . "/.john/john.pot");

	# Calculate any missing NT passwords from known
	# NT hashes.  Ugly to call this here, but too expensive
	# to call after every LM update.
	print "Updating NT passwords in database using LANMAN password\n";
	$y->update_nt_from_lm();
}

if ($command eq "rcrack") {
	my $table_dir = shift or die $usage;
	my $hash_type = shift or die $usage;

	if (lc $hash_type eq "ntlm" or lc $hash_type eq "nt") {
		$hash_type = "nt";
	}

	if (lc $hash_type eq "lanman" or lc $hash_type eq "lm") {
		$hash_type = "lanman";
	}

	unless ($hash_type eq "lanman" or $hash_type eq "nt") {
		die "ERROR: Rainbow tables cannot yet be used to crack $hash_type hashes\n";
	}

	my $temp_dir = tempdir(".rt-session-XXXXX", CLEANUP => 1);
	chdir $temp_dir;
	$temp_dir = `pwd`; chomp $temp_dir;
	my $filename = "$temp_dir/" . $y->get_hash_file( password_hash_type_name => $hash_type );

	unless (defined($filename)) {
		print "No passwords of type $hash_type to crack.  Exiting.\n";
		exit 0;
	}
	
	chdir $table_dir;
        $y->run_command_save_output(
                "cat $filename; rcrack *.rt -l $filename",
                "$temp_dir/rt-$hash_type.out",
        );

	$y->parse_rt("$temp_dir/rt-$hash_type.out");

	# Calculate any missing NT passwords from known
	# NT hashes.  Ugly to call this here, but too expensive
	# to call after every LM update.
	print "Updating NT passwords in database using LANMAN password\n";
	$y->update_nt_from_lm();
}

if ($command eq "stats") {
	printf "Stats for cracking of password hashes:\n\n";
	printf "%-14s%-9s%-12s%-14s\n", "Hash Type", "Count", "Cracked", "Uncracked";
	foreach my $hash_type ($y->get_hash_types) {
		printf "%-14s%-9s%-15s%-14s\n", $hash_type, $y->get_hash_count($hash_type), $y->get_cracked_hash_count($hash_type) . " (" . $y->get_cracked_hash_percentage($hash_type) . "%)", $y->get_uncracked_hash_count($hash_type) . " (" . $y->get_uncracked_hash_percentage($hash_type) . "%)";
	}
	print "\n";
}

$y->destroy;
