#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use IPC::SysV qw(IPC_CREAT SEM_UNDO);
use Digest::MD4 qw(md4 md4_hex md4_base64);
use File::Temp qw/ tempfile /;

my $port = 1241;
my ($host, $user, $pass, $ip, $ports, $outfile, $nessusclient);
my $usage = "
Usage: $0 -c /opt/nessus/bin/nessus -h ip[:port] -u user -p pass -i ip -p port1,port2,... -o output.nbe

This is a wrapper around NessusClient.  It is used by yaptest-nessus3.pl and 
should not be called directly.

All arguments are mandatory and have the following meaning:
    -c   Nessus client
    -h   Hostname of nessus server.  Optionally specify a port (default: $port)
    -u   Username to log into nessus server
    -p   Password to log into nessus server
    -i   IP Address to scan
    -p   Ports to scan (command separated list of TCP and UDP ports)
";

GetOptions (
        "host=s" => \$host,
        "user=s" => \$user,
        "client=s" => \$nessusclient,
        "pass=s" => \$pass,
        "ip=s" => \$ip,
        "ports=s" => \$ports,
        "outfile=s" => \$outfile,
);

unless (defined($host) and defined($port) and defined($user) and defined($pass) and defined($ports) and defined($outfile) and defined($nessusclient)) {
	print "ERROR: Missing arguments\n";
	print $usage;
	exit 1;
}

if ($host =~ /([0-9a-zA-Z_\.-]+):(\d+)/) {
	$host = $1;
	$port = $2;
}

print "\n";
print "Nessus host:   $host\n";
print "Nessus port:   $port\n";
print "Nessus user:   $user\n";
print "Nessus pass:   $pass\n";
print "Nessus client: $nessusclient\n";
print "Target:        $ip\n";
print "Port list:     $ports\n";
print "Output file:   $outfile\n";
print "\n";

my $plugin_prefs = "";
my $plugin_list = "";
my $server_prefs = "";

my $template_file = get_config_file_template($nessusclient);
my $ipfile = write_to_file($ip);
my $nessusrc_file = generate_nessusrc($template_file, $ip, $ports);
system($nessusclient, "-x", "-q", "-c", $nessusrc_file, $host, $port, $user, $pass, $ipfile, $outfile);
my $htmlfile = $outfile; $htmlfile =~ s/\.nbe$//; $htmlfile .= ".html";
system("cat", $outfile);
system($nessusclient, "-i", $outfile, "-o", $htmlfile);
print "Nessus scan of $ip complete.  Report output saved to $outfile and $htmlfile\n";
unlink $ipfile;
unlink $nessusrc_file;

sub generate_nessusrc {
	my $template_file = shift;
	my $ip = shift;
	my $ports = shift;
	undef $/;
	open TEMPLATE, "<$template_file" or die "ERROR: Couldn't open template file $template_file: $!\n";
	my $nessusrc = <TEMPLATE>;
	close TEMPLATE;
	$nessusrc =~ s/port_range = \S+/port_range = $ports/;
	$nessusrc =~ s/targets =[^\r\n]*/targets = $ip/;
	$nessusrc =~ s/ *unscanned_closed =[^\r\n]*/unscanned_closed = yes/;
	$nessusrc =~ s/ *safe_checks =[^\r\n]*/safe_checks = yes/;
	$nessusrc =~ s/ *optimize_test = [^\r\n]*/optimize_test = 0/;
	$nessusrc =~ s/ *Test the local Nessus host = yes/Test the local Nessus host = no/;
	my ($fh, $filename) = tempfile(".nessusrc-XXXXX");
	print $fh $nessusrc;
	print "Wrote nessusrc file to $filename\n";
	close($fh);
	return $filename;
}

sub write_to_file {
	my $ip = shift;
	my ($fh, $filename) = tempfile(".nessus-ip-XXXXX");
	print $fh "$ip\n";
	close $fh;
	return $filename;
}

sub get_config_file_template {
	my $file_base = ".nessusrc_template";
	if ($nessusclient =~ /openvas/i) {
		$file_base = ".openvasrc_template";
	}

	# Check config file is read/writable.  Change filename if necessary.
	my $suffix = 0;
	my $file = $file_base;
	semaphore_take("nessus_gen");
	print "Searching for nessusrc template file\n";
	while (-e $file and (! -r $file or ! -w $file)) {
		print "\t trying $file\n";
		$suffix++;
		$file = $file_base . ".$suffix";
	}

	if (-e $file) {
		# Check if it's a recent file (24 hours)
		my $mtime = (stat($file))[9];
		my $now = time;
		if (($now - $mtime) < 24*60*60) {
			print "\t$file has been modified in the last 24 hours.  We'll use that.\n";
			semaphore_give("nessus_gen");
			return $file;
		}
	}

	print "\t$file will be generated now.\n\n";
	open OUTFILE, ">$file" or die "ERROR: Tried to open $file for writing, but failed: $!";

	open (PREFS, "$nessusclient -x -q -P $host $port '$user' '$pass' |") or die "ERROR: Can't run Nessus: $!\n";
	while (<PREFS>) {
		my $line = $_;
		if ($line =~ /\[.*\]:.* = /) {
			$plugin_prefs .= $line;
		} else {
			$server_prefs .= $line;
		}
	}
	close(PREFS);
	
	open (PLUGINS, "$nessusclient -x -q -p $host $port '$user' '$pass' |") or die "ERROR: Can't run Nessus: $!\n";
	while (<PLUGINS>) {
		my $line = $_;
		my ($id) = $line =~ /^(\d+)|/;
		$plugin_list .= " $id = yes\n"
	}
	close(PLUGINS);
	
	print OUTFILE "trusted_ca = /usr/com/nessus/CA/cacert.pem
nessusd_user = $user
paranoia_level = 1
hide_toolbar = no
hide_msglog = no
targets = 
use_ssl = yes
use_client_cert = no
nessusd_port = $port
begin(SCANNER_SET)
 10180 = yes
 10277 = yes
 10278 = yes
 10331 = no
 10335 = yes
 10841 = no
 10336 = no
 10796 = no
 11219 = no
 14259 = no
 14272 = no
 14274 = no
 14663 = no
 11840 = yes
end(SCANNER_SET)

begin(SERVER_PREFS)
$server_prefs" . "end(SERVER_PREFS)

begin(SERVER_INFO)
 server_info_nessusd_version = 3.0.6
 server_info_libnasl_version = 3.0.6
 server_info_libnessus_version = 3.0.6
 server_info_thread_manager = fork
 server_info_os = Linux
 server_info_os_version = 2.6.13-15-smp
end(SERVER_INFO)

begin(RULES)
end(RULES)

begin(PLUGINS_PREFS)
$plugin_prefs" . "end(PLUGINS_PREFS)

begin(PLUGIN_SET)
$plugin_list" . "end(PLUGIN_SET)

begin(CLIENTSIDE_USERRULES)
end(CLIENTSIDE_USERRULES)
";
	close OUTFILE;
	semaphore_give("nessus_gen");
	return $file;
}

sub semaphore_take {
        my $res_name = shift;
        my $res_id = res_name_to_sem_id($res_name);
        my $id = semget($res_id, 1, 0666 | IPC_CREAT );
        die "ERROR: Could not get create/use semaphore: $!\n" if !defined($id);

        my $semnum = 0;
        my $semflag = SEM_UNDO;

        # 'take' semaphore
        # wait for semaphore to be zero
        my $semop = 0;
        my $opstring1 = pack("s!s!s!", $semnum, $semop, $semflag);

        # Increment the semaphore count
        $semop = 1;
        my $opstring2 = pack("s!s!s!", $semnum, $semop,  $semflag);
        my $opstring = $opstring1 . $opstring2;

        semop($id, $opstring) || die "$!";
}

sub semaphore_give {
        my $res_name = shift;
        my $res_id = res_name_to_sem_id($res_name);
        my $id = semget($res_id, 1, 0666 | IPC_CREAT );
        die "ERROR: Could not get create/use semaphore: $!\n" if !defined($id);

        my $semnum = 0;
        my $semflag = SEM_UNDO;

        # Decrement the semaphore count
        my $semop = -1;
        my $opstring = pack("s!s!s!", $semnum, $semop, $semflag);

        semop($id, $opstring) || die "$!";
}

sub res_name_to_sem_id {
        my $res_name = shift;
        return unpack("N", substr(md4(`pwd` . $res_name), 0, 4));
}
