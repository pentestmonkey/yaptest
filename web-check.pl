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
		$loc =~ s!../!/!g; # firefox, wget do this
		if ($loc =~ /^\//) {
			$new_url = "$scheme://$ip:$port/$loc";
			print "[+] Redirecting to $new_url\n";
			$redirects++;
		} else {
			print "[E] Not redirecting to $loc\n";
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

output_info($url, "html_title", $title);
output_info($url, "ssl_subject", $ssl_subject);
output_info($url, "ssl_issuer", $ssl_issuer);
output_info($url, "http_server_header", $http_server_header);
output_info($url, "http_x_powered_by", $http_x_powered_by);
output_info($url, "homepage_url", $new_url);
output_info($url, "homepage_content_b64", $res->content);
output_info($url, "homepage_headers_b64", $res->headers->as_string);

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

