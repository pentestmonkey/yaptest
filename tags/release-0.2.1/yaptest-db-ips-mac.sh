#!/bin/sh

if [ ! -z $1 ]; then
	echo "Usage: $0 dict-dir"
	exit 0
fi

# TCP Port-based tests
# Continue with these while we wait for UDP scan to finish
tcp_port_based_tests () {
	yaptest-rpcinfo.pl
	rpcinfo_based_tests
	yaptest-nxscan.pl
	yaptest-ms08-067-check.pl
	yaptest-ident-user-enum.pl
	yaptest-dcetest.pl
	yaptest-nmap-tcp.pl openonly
	yaptest-parse-nmap-xml.pl nmap-tcp*.xml
	yaptest-tnscmd.pl
	yaptest-oscanner.pl
	nmap_service_based_tests
	yaptest-bannergrab.pl
	yaptest-finger-user-enum.pl
	yaptest-smtp-user-enum.pl
	yaptest-amap-tcp.pl
	yaptest-vessl.pl
	yaptest-sslscan.pl
	yaptest-httprint.pl
	yaptest-smtpscan.pl
	yaptest-x-open.pl
	yaptest-hoppy.pl
	yaptest-enum4linux.pl
	yaptest-ssh-keyscan.pl
	yaptest-sshprobe.pl
	password_guessing
}

nmap_service_based_tests () {
	yaptest-ldapsearch.pl
	yaptest-telnet-fuser.pl
	yaptest-nikto.pl &
}

rpcinfo_based_tests () {
	# Tests based on output of rpcinfo
	yaptest-rexd.pl
	yaptest-kcmsd-fileread.pl
	yaptest-showmount.pl
	yaptest-rup.pl
	yaptest-rusers.pl
}

password_guessing () {
	# Most password guessing turned off by default to
	# avoid accidentially locking accounts

	# yaptest-password-guess-ftp.pl
	yaptest-password-guess-mssql.pl
	# yaptest-password-guess-rlogin.pl
	# yaptest-password-guess-smb.pl
	# yaptest-password-guess-ssh.pl
}

# Quick TCP portscan followed by 
yaptest-dns-grind-ptr.pl     # Get DNS PTR records
yaptest-nmap-tcp.pl quick    # Quick TCP port scan
yaptest-parse-nmap-xml.pl nmap-tcp*.xml
yaptest-udp-proto-scanner.pl
yaptest-nmap-udp.pl &        # To UDP scans in background while we test
                             # the TCP services found.
yaptest-nbtscan.pl           # Get windows hostname info
tcp_port_based_tests         # Test the TCP services found so far.

# Some scans that run against every IP
yaptest-ike-scan.pl
yaptest-ping-r.pl
yaptest-onesixtyone.pl
yaptest-nmap-ip-protocols.pl &

# Complete the TCP-based testing
yaptest-nmap-tcp.pl full    # Find remaining TCP services
yaptest-parse-nmap-xml.pl nmap-tcp*.xml
tcp_port_based_tests        # Test the remaining TCP services

# Tests based on other stuff
yaptest-snmpwalk.pl

# Get topology info
yaptest-ping-r.pl
yaptest-traceroute.pl &

# Wait for UDP nmap scan then run some UDP-based tests
wait
yaptest-parse-nmap-xml.pl nmap-udp*.xml 
yaptest-nessus3.pl
yaptest-issues.pl parse nessus-report-*.html
yaptest-openvas.pl
yaptest-amap-udp.pl
yaptest-bannergrab.pl
yaptest-fpdns.pl
yaptest-dns.pl
yaptest-ntp.pl
yaptest-tftp.pl
