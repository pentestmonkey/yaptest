Description: Fix yaptest-nikto.pl
 Nikto is installed as nikto not nikto.pl in Debian.
 .
 yaptest (0.2.1.69-1) unstable; urgency=low
 .
   * Initial release
Author: Tim Brown <timb@nth-dimension.org.uk>

---
The information above should follow the Patch Tagging Guidelines, please
checkout http://dep.debian.net/deps/dep3/ to learn about the format. Here
are templates for supplementary fields that you might want to add:

Origin: <vendor|upstream|other>, <url of original patch>
Bug: <url in upstream bugtracker>
Bug-Debian: https://bugs.debian.org/<bugnumber>
Bug-Ubuntu: https://launchpad.net/bugs/<bugnumber>
Forwarded: <no|not-needed|url proving that it has been forwarded>
Reviewed-By: <name and email of someone who approved the patch>
Last-Update: <YYYY-MM-DD>

--- yaptest-0.2.1.69.orig/yaptest-nikto.pl
+++ yaptest-0.2.1.69/yaptest-nikto.pl
@@ -18,7 +18,7 @@ die $usage if shift;
 my $y = yaptest->new();
 
 $y->run_test(
-	command => "nikto.pl -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
+	command => "nikto -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
 	parallel_processes => $max_processes,
 	output_file => "nikto-http-::IP::-::PORT::.out",
 	filter => { port_info => "nmap_service_name like http", ssl => 0 },
@@ -28,7 +28,7 @@ $y->run_test(
 );
 
 $y->run_test(
-	command => "nikto.pl -ssl -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
+	command => "nikto -ssl -nolookup 127.0.0.1 -h ::IP:: -p ::PORT::",
 	parallel_processes => $max_processes,
 	output_file => "nikto-https-::IP::-::PORT::.out",
 	filter => { port_info => "nmap_service_name like http", ssl => 1 },
