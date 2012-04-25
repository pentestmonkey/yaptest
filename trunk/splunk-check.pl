#!/usr/bin/env perl
use strict;
use URI;
use warnings;
use HTTP::Request::Common qw(GET POST);
use LWP::UserAgent;
use HTTP::Cookies;

my %vulns;
$vulns{65638} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{67724} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{69401} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{70313} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{72459} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{73243} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{74233} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269 BID40930)];
$vulns{78281} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID40930)];
$vulns{79191} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID40930)];
$vulns{80534} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323)];
$vulns{82143} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323)];
$vulns{85165} = [qw(BID50296 BID50298)];
$vulns{89596} = [qw(BID50296 BID50298)];
$vulns{77833} = [qw(BID50296 BID50298 BID43276 CVE-2010-3322 CVE-2010-3323 BID41269)];
$vulns{95063} = [qw(BID50296 BID50298)];
$vulns{97242} = [qw(BID50296 BID50298)];
$vulns{98164} = [qw(CVE-2011-4778 BID50296 BID51061 BID50298)];
$vulns{101277} = [qw(SPL-45172 CVE-2011-4642 CVE-2011-4644 CVE-2011-4778 BID50296 BID51061 BID50298)];
$vulns{105575} = [qw(SPL-45172 CVE-2011-4642 CVE-2011-4644 CVE-2011-4778 BID50296 BID51061 BID50298)];
$vulns{110225} = [qw(SPL-45172 CVE-2011-4642 CVE-2011-4644 CVE-2011-4778 BID51061)];
$vulns{113966} = [qw()];

my %version_of;
$version_of{65638} = "4.0.3";
$version_of{67724} = "4.0.4";
$version_of{69401} = "4.0.5";
$version_of{70313} = "4.0.6";
$version_of{72459} = "4.0.7";
$version_of{73243} = "4.0.8";
$version_of{74233} = "4.0.9";
$version_of{78281} = "4.1.1";
$version_of{79191} = "4.1.2";
$version_of{80534} = "4.1.3";
$version_of{82143} = "4.1.4";
$version_of{85165} = "4.1.5";
$version_of{89596} = "4.1.6";
$version_of{77833} = "4.1";
$version_of{95063} = "4.1.7";
$version_of{97242} = "4.1.8";
$version_of{98164} = "4.2.1";
$version_of{101277} = "4.2.2";
$version_of{105575} = "4.2.3";
$version_of{110225} = "4.2.4";
$version_of{113966} = "4.2.5";
$version_of{96430} = "4.2";
$version_of{98164} = "4.2.1";
$version_of{101277} = "4.2.2";
$version_of{105575} = "4.2.3";
$version_of{110225} = "4.2.4";
$version_of{113966} = "4.2.5";
$version_of{96430} = "4.2";

my %vuln_info;
$vuln_info{"CVE-2011-4642"} = {
	description => "mappy.py in Splunk Web in Splunk 4.2.x before 4.2.5 does not properly restrict use of the mappy command to access Python classes, which allows remote authenticated administrators to execute arbitrary code by leveraging the sys module in a request to the search application, as demonstrated by a cross-site request forgery (CSRF) attack, aka SPL-45172.",
};

$vuln_info{"CVE-2011-4643"} = {
	description => "Multiple directory traversal vulnerabilities in Splunk 4.x before 4.2.5 allow remote authenticated users to read arbitrary files via a .. (dot dot) in a URI to (1) Splunk Web or (2) the Splunkd HTTP Server, aka SPL-45243.",
};

$vuln_info{"CVE-2011-4644"} = {
	description => "Splunk 4.2.5 and earlier, when a Free license is selected, enables potentially undesirable functionality within an environment that intentionally does not support authentication, which allows remote attackers to (1) read arbitrary files via a management-console session that leverages the ability to create crafted data sources, or (2) execute management commands via an HTTP request.",
};

$vuln_info{"CVE-2011-4778"} = {
	description => "Cross-site scripting (XSS) vulnerability in Splunk Web in Splunk 4.2.x before 4.2.5 allows remote attackers to inject arbitrary web script or HTML via unspecified vectors, aka SPL-44614.",
};

$vuln_info{"BID51061"} = {
	title => "Splunk Cross Site Scripting and Cross Site Request Forgery Vulnerabilities",
	date => "2011-10-20",
};

$vuln_info{"BID50296"} = {
	title => "Splunk 'segment' Parameter Cross Site Scripting Vulnerability",
	date => "2011-10-20",
};

$vuln_info{"BID50298"} = {
	title => "Splunk Web component Remote Denial of Service Vulnerability",
	date => "2011-10-20",
};

$vuln_info{"BID43276"} = {
	title => "Splunk Session Hijacking and Information Disclosure Vulnerabilities",
	date => "2010-09-09",
};

$vuln_info{"BID41269"} = {
	title => "Splunk Cross Site Scripting and Directory Traversal Vulnerabilities",
	date => "2010-06-30",
};

$vuln_info{"BID40930"} = {
	title => "Splunk HTTP 'Referer' Header Cross Site Scripting Vulnerability",
	date => "2010-06-07",
};

# Generate URL references
foreach my $build (keys %vulns) {
	foreach my $id (@{$vulns{$build}}) {
		if (!defined($vuln_info{$id})) {
			$vuln_info{$id} = {};
		}
		if ($id =~ /^BID(\d+)/) {
			$vuln_info{$id}{link} = "http://www.securityfocus.com/bid/$1";
		}
		if ($id =~ /^CVE/) {
			$vuln_info{$id}{link} = "http://cve.mitre.org/cgi-bin/cvename.cgi?name=" . $id;
		}
		if ($id =~ /^SPL-(\d+)/) {
			$vuln_info{$id}{link} = "http://www.splunk.com/view/SP-CAAAGMM#" . $1;
		}
	}
}

#set an env which will ignore cert errors
$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

my $ua = LWP::UserAgent->new;
my $usage = "$0 url

e.g. for management server: $0 http://host:8000
     for forwarder:         $0 https://host:8089

";

my $url_dirty = shift or die $usage;
my $uri_obj = URI->new($url_dirty);
my $ip = $uri_obj->host;
my $url = $uri_obj->canonical;

push @{ $ua->requests_redirectable }, 'POST';
$ua->cookie_jar( HTTP::Cookies->new());
$ua->cookie_jar()->set_cookie(1, "cval", "1", "/", $ip);

my $req;
my $res;
my $version;
my $build;
my $type = "unknown";

$req = GET $url;
$res = $ua->request($req);
if ($res->is_success and $res->content =~ /Splunk\s+([\d\.]+)\s+build\s+(\d+)/s) {
# if ("Splunk 4.2.3 build 105575" =~ /Splunk\s+([\d\.]+)\s+build\s+(\d+)/s) { # TODO
	$version = $1;
	$build = $2;
	$type = "server";
	print "[V] Splunk management server detected on $url\n";
	print "[V] Splunk Version $version Build $build on $url\n";
} elsif ($res->is_success and $res->content =~ /Atom.*generator version="(\d+)"/sg) {
	$build = $1;
	$type = "forwarder";
	print "[V] Splunk forwarder detected on $url\n";
	print "[V] Splunk Version on $url: Build $build\n";
	if (my $version = $version_of{$build}) {
		print "[V] Splunk Version Lookup: $version\n";
	}
} else {
	print "[E] Not a splunk server\n";
}

if ($build) {
	list_vulns($build);
}

if ($type eq "server") {
	print "[i] Attempting login to server\n";
	$req = POST $url . "en-US/account/login", [ cval => 1, return_to => "/en-US/", username => "admin", password => "changeme" ];
	$res = $ua->request($req);
	if ($res->is_success and $res->content =~ /Welcome.*Splunk Home/s) {
		print "[V] Logged into $url with default credentials: admin/changeme\n";
	} else {
		print "[+] Could not log in with default credentials\n";
	}
}

if ($type eq "forwarder") {
	print "[i] Attempting login to forwarder\n";
	$req = GET $url . "servicesNS";
	$req->authorization_basic('admin', 'changeme');
	$res = $ua->request($req);
	if ($res->content =~ /Remote login has been disabled for 'admin/s) {
		print "[V] Remote logins not allowed, but default credentials are in use for $url" . "servicesNS/: admin/changeme\n";
	} elsif ($res->content =~ /401 Unauthorized/s) {
		print "[+] Default login credentials have been changed for $url\n";
	} else {
		print "[W] Unexpected response from $url while logging into forwarder: ";
		print $res->content;
	}
}

sub list_vulns {
	my $build = shift(@_);
	if ($vulns{$build}) {
		print "[V] Vulnerable version of splunk detected on $url.  Vulnerabilities for build $build: ";
		print join(" ", @{$vulns{$build}}) . "\n";
		foreach my $id (@{$vulns{$build}}) {
			print "--------------------------\n";
			print "Info for $id:\n";
			foreach my $k (keys %{$vuln_info{$id}}) {
				printf "\t%s: %s\n", $k, $vuln_info{$id}{$k};
			}
		}
	} else {
		print "[+] No vulnerabilities known for build $build on $url\n";
	}
}

