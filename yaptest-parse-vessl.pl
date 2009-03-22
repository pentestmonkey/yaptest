#!/usr/bin/env perl
# Contributed by deanx.
use strict;
use warnings;
use POSIX;
use Getopt::Long;
use yaptest;
use File::Basename;

my $script_name = basename($0);
my $usage = "Usage: $script_name vessl.out [ vessl.out.2 ]

Parses vessl output for ssl hostnames, and certificate-related issues.
";

my $file = shift or die $usage;
unshift @ARGV, $file;

my %good_issue = (
	"2" => "ssl_cert_cant_get_issuer_cert",
	"4" => "ssl_cert_cant_decrypt_certs_sig",
	"5" => "ssl_cert_cant_decrypt_crls_sig",
	"6" => "ssl_cert_issuer_pub_key_decode_fail",
	"7" => "ssl_cert_certificate_signature_failure",
	"8" => "ssl_cert_crl_signature_failure",
	"9" => "ssl_cert_certificate_is_not_yet_valid",
	"10" => "ssl_cert_certificate_has_expired",
	"11" => "ssl_cert_crl_is_not_yet_valid",
	"12" => "ssl_cert_crl_has_expired",
	"13" => "ssl_cert_bad_format_in_notbefore",
	"14" => "ssl_cert_bad_format_in_notafter",
	"15" => "ssl_cert_bad_format_in_lastupdate",
	"16" => "ssl_cert_bad_format_in_nextupdate",
	"17" => "ssl_cert_out_of_memory",
	"18" => "ssl_cert_self_signed_cert",
	"19" => "ssl_cert_self_signed_cert_in_cert_chain",
	"20" => "ssl_cert_unable_get_local_issuer_cert",
	"21" => "ssl_cert_unable_to_verify_the 1st_cert",
	"22" => "ssl_cert_cert_chain_too_long",
	"23" => "ssl_cert_certificate_revoked",
	"24" => "ssl_cert_invalid_ca_certificate",
	"25" => "ssl_cert_path_length_constraint_exceeded",
	"26" => "ssl_cert_unsupported_cert_purpose",
	"27" => "ssl_cert_certificate_not_trusted",
	"28" => "ssl_cert_certificate_rejected",
	"29" => "ssl_cert_subject_issuer_mismatch",
	"30" => "ssl_cert_authority_and_subject_key_identifier_mismatch",
	"31" => "ssl_cert_authority_and_issuer_serial_number_mismatch",
	"32" => "ssl_cert_key_usage_does_not_include_cert_signing",
	"50" => "ssl_cert_application_verification_failure",
	"98" => "ssl_cert_blacklisted_debian_key",
	"99" => "ssl_cert_host_ip_vs_cert_ip_mismatch"
	);

my $y = yaptest->new();

while (my $filename = shift) {
	my $ip;
	my $port;
	my $trans = "TCP";
	print "Processing $filename ...\n";

	unless (open(FILE, "<$filename")) {
		print "WARNING: Can't open $filename for reading.  Skipping...\n";
		next;
	}

	while (<FILE>) {
		print;
		chomp;
		my $line = $_;
		if ($line =~ /Connecting to.*:(\d+).*?(\d+\.\d+\.\d+\.\d+)/){
			$ip = $2;
			$port = $1;
			print "Parsing Issues for $ip:$port\n"
		}
		if ($line =~ /verify error:num=(\d+):/){
			my $issue = $1;
			if (defined($good_issue{$issue}) and $ip and $port) {
				print "PARSED: $ip:$port/$trans issue $issue (" . $good_issue{$issue} . ")\n";
				$y->insert_issue(name => substr($good_issue{$issue}, 0, 59), description =>$good_issue{$issue},  ip_address => $ip, port => $port, transport_protocol => $trans);
				}
		}			
		if ($line =~ /(\d+\.\d+\.\d+\.\d+):(\d+), (\S*) \(/) {
			my $ip2 = $1;
			my $port2 = $2;
			my $hostname = $3;
			$y->insert_hostname(type => 'ssl_hostname', ip_address => $ip2, hostname => $hostname);
			$y->insert_port_info(
            	ip                 => $ip2,
                port               => $port2,
                transport_protocol => $trans,
                port_info_key      => "ssl_hostname",
                port_info_value    => $hostname
            );
		}
	}
}
$y->commit;
$y->destroy;
