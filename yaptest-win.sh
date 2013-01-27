#!/bin/sh

if [ ! -z $1 ]; then
	echo "Usage: $0 dict-dir"
	exit 0
fi

if [ `id -u` != "0" ]; then
	echo "ERROR: Your UID/EUID isn't 0.  You need to root to run some tests.  Use sudo or run as root.\n"
	exit 1;
fi

# TCP Port-based tests
# Continue with these while we wait for UDP scan to finish
tcp_port_based_tests () {
	yaptest-nxscan.pl
	yaptest-ms08-067-check.pl
	yaptest-nmap-tcp.pl openonly
	yaptest-parse-nmap-xml.pl nmap-tcp*.xml
	yaptest-amap-tcp.pl
	yaptest-enum4linux.pl
	password_guessing
}

nmap_service_based_tests () {
	yaptest-ldapsearch.pl
}

password_guessing () {
	# Most password guessing turned off by default to
	# avoid accidentially locking accounts

	# yaptest-password-guess-ftp.pl
	# yaptest-password-guess-mssql.pl
	# yaptest-password-guess-rlogin.pl
	yaptest-password-guess-smb.pl
	# yaptest-password-guess-ssh.pl
}

# Quick TCP portscan followed by 
yaptest-yapscan-tcp.pl 53,139,445,389,135 # Quick TCP port scan
# yaptest-yapscan-tcp.pl quick # Quick TCP port scan
#yaptest-nmap-udp.pl &        # To UDP scans in background while we test
                             # the TCP services found.
yaptest-udp-proto-scanner-win.pl
yaptest-nbtscan.pl           # Get windows hostname info
tcp_port_based_tests         # Test the TCP services found so far.

# Some scans that run against every IP
yaptest-onesixtyone.pl

# Tests based on other stuff
yaptest-snmpwalk.pl

# Wait for UDP nmap scan then run some UDP-based tests
wait
yaptest-parse-nmap-xml.pl nmap-udp*.xml 
yaptest-issues.pl insecgen
