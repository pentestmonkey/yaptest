#!/usr/bin/env perl
use strict;
use URI;
use warnings;
use HTTP::Request::Common qw(GET POST);
use LWP::UserAgent;
use HTTP::Cookies;

my %vulns;
my %version_of;
$version_of{65638} = "4.0.3"; $vulns{65638} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{67724} = "4.0.4"; $vulns{67724} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{69401} = "4.0.5"; $vulns{69401} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{70313} = "4.0.6"; $vulns{70313} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{72459} = "4.0.7"; $vulns{72459} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{73243} = "4.0.8"; $vulns{73243} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{74233} = "4.0.9"; $vulns{74233} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269 BID40930)];
$version_of{78281} = "4.1.1"; $vulns{78281} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429  SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID40930)];
$version_of{79191} = "4.1.2"; $vulns{79191} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 BID50296 BID50298 BID43276 BID40930)];
$version_of{80534} = "4.1.3"; $vulns{80534} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 BID50296 BID50298 BID43276)];
$version_of{82143} = "4.1.4"; $vulns{82143} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 BID50296 BID50298 BID43276)];
$version_of{85165} = "4.1.5"; $vulns{85165} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 BID50296 BID50298)];
$version_of{89596} = "4.1.6"; $vulns{89596} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 BID50296 BID50298)];
$version_of{77833} = "4.1"; $vulns{77833} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 BID50296 BID50298 BID43276 BID41269)];
$version_of{95063} = "4.1.7"; $vulns{95063} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 BID50296 BID50298)];
$version_of{97242} = "4.1.8"; $vulns{97242} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 BID50296 BID50298)];
$version_of{98164} = "4.2.1"; $vulns{98164} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 BID50296 BID51061 BID50298)];
$version_of{60883} = "3.4.10"; $vulns{60883} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{61120} = "3.4.10"; $vulns{61120} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{65313} = "3.4.11"; $vulns{65313} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{69236} = "3.4.12"; $vulns{69236} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{75215} = "3.4.13"; $vulns{75215} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS )];
$version_of{45588} = "3.4.1"; $vulns{45588} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{79166} = "3.4.14"; $vulns{79166} = [qw(CVE-2012-0876.CVE-2010-3864 )];
$version_of{46047} = "3.4.2"; $vulns{46047} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{46779} = "3.4.3"; $vulns{46779} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{44873} = "3.4"; $vulns{44873} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{47883} = "3.4.5"; $vulns{47883} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{51113} = "3.4.6"; $vulns{51113} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{52639} = "3.4.6"; $vulns{52639} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{54309} = "3.4.8"; $vulns{54309} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{57762} = "3.4.9"; $vulns{57762} = [qw(CVE-2012-0876.CVE-2010-3864 SP-CAAAFGS)];
$version_of{77146} = "4.0.10"; $vulns{77146} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS  SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 )];
$version_of{79031} = "4.0.11"; $vulns{79031} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 )];
$version_of{64658} = "4.0.1"; $vulns{64658} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 )];
$version_of{64889} = "4.0.2"; $vulns{64889} = [qw(SPL-50671 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 SPL-34355 CVE-2010-3864 SPL-31061   CVE-2010-3322 SPL-31094   CVE-2010-3323 SPL-31736   CVE-2010-2429 SP-CAAAFGS SPL-31194   CVE-2010-2502   SPL-31063   CVE-2010-2502  SPL-31067   CVE-2010-2503    SPL-31084   CVE-2010-2503  SPL-31085   CVE-2010-2503  SPL-31066   CVE-2010-2504 )];
$version_of{101277} = "4.2.2"; $vulns{101277} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 CVE-2011-4644 BID50296 BID51061 BID50298)];
$version_of{103356} = "4.2.2.1"; $vulns{103356} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 )];
$version_of{105575} = "4.2.3"; $vulns{105575} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 BID50296 BID51061 BID50298 CVE-2011-4644)];
$version_of{110225} = "4.2.4"; $vulns{110225} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 CVE-2011-4644 BID51061)];
$version_of{113966} = "4.2.5"; $vulns{113966} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 )];
$version_of{96430} = "4.2"; $vulns{96430} = [qw(SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 SPL-44614  CVE-2011-4778  SPL-45172  CVE-2011-4642 :SPL-45243  CVE-2011-4643 SPL-42471 SPL-42474 SPL-40645 SPL-40804 SPL-38704 SPL-38585 )];
$version_of{119532} = "4.3.1"; $vulns{119532} = [qw(SPL-60629   CVE-2013-2766 SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876.)];
$version_of{115073} = "4.3"; $vulns{115073} = [qw(SPL-60629   CVE-2013-2766 SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876. SPL-38585  CVE-2012-1908 )];
$version_of{123586} = "4.3.2"; $vulns{123586} = [qw(SPL-60629   CVE-2013-2766 SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876.)];
$version_of{128297} = "4.3.3"; $vulns{128297} = [qw(SPL-60629   CVE-2013-2766 SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876.)];
$version_of{136012} = "4.3.4"; $vulns{136012} = [qw(SPL-60629   CVE-2013-2766 SPL-50671 SPL-55157 SPL-55521 CVE-2012-0876.)];
$version_of{140437} = "4.3.5"; $vulns{140437} = [qw(SPL-60629   CVE-2013-2766 )];
$version_of{153775} = "4.3.6"; $vulns{153775} = [qw()];
$version_of{181874} = "4.3.7"; $vulns{181874} = [qw()];
$version_of{143156} = "5.0.1"; $vulns{143156} = [qw(SPL-59895  CVE-2012-6447  SPL-60250  CVE-2013-6773  SPL-61546  CVE-2013-0169  CVE-2013-0166 SPL-65987  CVE-2013-6772 SPL-70250  CVE-2013-6771 SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{140868} = "5.0"; $vulns{140868} = [qw(SPL-59895  CVE-2012-6447  SPL-60250  CVE-2013-6773  SPL-61546  CVE-2013-0169  CVE-2013-0166 SPL-65987  CVE-2013-6772 SPL-70250  CVE-2013-6771 SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{149561} = "5.0.2"; $vulns{149561} = [qw(SPL-59895  CVE-2012-6447  SPL-60250  CVE-2013-6773  SPL-61546  CVE-2013-0169  CVE-2013-0166 SPL-65987  CVE-2013-6772 SPL-70250  CVE-2013-6771 SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{163460} = "5.0.3"; $vulns{163460} = [qw( SPL-65987  CVE-2013-6772 SPL-70250  CVE-2013-6771 SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{172409} = "5.0.4"; $vulns{172409} = [qw( SPL-70250  CVE-2013-6771 SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{179365} = "5.0.5"; $vulns{179365} = [qw( SPL-74327  CVE-2013-6998 SPL-74017  CVE-2014-2578 )];
$version_of{185560} = "5.0.6"; $vulns{185560} = [qw( SPL-74017  CVE-2014-2578 )];
$version_of{192438} = "5.0.7"; $vulns{192438} = [qw(SPL-74017  CVE-2014-2578 )];
$version_of{201809} = "5.0.8"; $vulns{201809} = [qw( )];
$version_of{189883} = "6.0.1"; $vulns{189883} = [qw( SPL-82696  CVE-2014-0160  SPL-78823  CVE-2013-4353 SPL-79922  CVE-2014-3147 )];
$version_of{182037} = "6.0"; $vulns{182037} = [qw(SPL-75668  CVE-2013-7337 SPL-82696  CVE-2014-0160  SPL-78823  CVE-2013-4353 SPL-79922  CVE-2014-3147 )];
$version_of{196940} = "6.0.2"; $vulns{196940} = [qw(SPL-82696  CVE-2014-0160  SPL-78823  CVE-2013-4353 SPL-79922  CVE-2014-3147 )];
$version_of{204106} = "6.0.3"; $vulns{204106} = [qw( SPL-79922  CVE-2014-3147 )];
$version_of{207768} = "6.0.4"; $vulns{207768} = [qw(  )];
$version_of{206881} = "6.1.0"; $vulns{206881} = [qw()];
$version_of{207789} = "6.1.1"; $vulns{207789} = [qw()];

# forwarders
$version_of{98164} = "4.2.1";
$version_of{101277} = "4.2.2"; 
$version_of{103356} = "4.2.2.1";
$version_of{105575} = "4.2.3";
$version_of{110225} = "4.2.4";
$version_of{113966} = "4.2.5";
$version_of{96430} = "4.2";
$version_of{119532} = "4.3.1";
$version_of{115073} = "4.3";
$version_of{123586} = "4.3.2";
$version_of{128297} = "4.3.3";
$version_of{136012} = "4.3.4";
$version_of{140437} = "4.3.5";
$version_of{153775} = "4.3.6";
$version_of{181874} = "4.3.7";
$version_of{143156} = "5.0.1";
$version_of{140868} = "5.0";
$version_of{149561} = "5.0.2";
$version_of{163460} = "5.0.3";
$version_of{172409} = "5.0.4";
$version_of{179365} = "5.0.5";
$version_of{185560} = "5.0.6";
$version_of{192438} = "5.0.7";
$version_of{201809} = "5.0.8";
$version_of{189883} = "6.0.1";
$version_of{182037} = "6.0";
$version_of{182611} = "6.0"; $vulns{182611} = [qw(SPL-75668 CVE-2013-7337 SPL-82696 CVE-2014-0160 SPL-78823 CVE-2013-4353 SPL-79922 CVE-2014-3147)];
$version_of{196940} = "6.0.2";
$version_of{204106} = "6.0.3";
$version_of{207768} = "6.0.4";
$version_of{206881} = "6.1.0";

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
			$vuln_info{$id}{link} = "https://www.google.co.uk/#q=" . $1;
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
} elsif ($res->is_success and $res->content =~ /Atom.*generator version="(\d+)"/sg or $res->content =~ /Atom.*generator build="(\d+)"/s) {
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
		print $res->content;
		print "[V] Logged into $url with default credentials: admin/changeme\n";
	} else {
		print "[+] Could not log in with default credentials\n";
	}
}

if ($type eq "forwarder") {
	print "[i] Attempting login to forwarder\n";
	$req = GET $url . "servicesNS";
#	print "[D] admin/changeme\n";
	$req->authorization_basic('admin', 'changeme');
	$res = $ua->request($req);
#	print $res->content;

	#print "[D] admin/changemX\n";
#	$req->authorization_basic('admin', 'changemX');
#	$res = $ua->request($req);
#	print $res->content;

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

