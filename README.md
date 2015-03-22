A penetration testing framework that helps automate the boring parts of pentests

=== Yet Another PenTEST... ===

Work in progress: This project has not yet been moved to google code.  See also the [http://pentestmonkey.net/projects/yaptest/yaptest-overview/ official homepage] and [http://thegreyhats.blogspot.co.uk/2012/03/getting-yaptest-to-run-under-ubuntu.html freakyclown's install notes].

At times pentesting is one of the most fun jobs around.  Other times, though it's dull.  When you're having to manually check for the same issues on the next host and the next host and the next... testing can get kinda tedious.  

Vulnerability scanners (nessus and the like) have their place, but no scanner is going to test for everything that you're interested in.   Yaptest aims to make it easy for a pentester to automate parts of testing on the fly.  This is particularly useful when testing very large networks.  Below are some examples of tasks which would be easy to automate using yaptest:

    * Run nikto on anything nmap thinks is an HTTP service
    * Run hydra on every host with TCP port 21 open
    * Attempt upload a file to any TFTP servers found
    * Run onesixtyone on all hosts that are up
    * Try metasploit's solaris_kcms_readfile exploit against any hosts running kcmsd

Yaptest is the glue between your favourite tools and the knowledge base gathered during your pentest.  It handles all the mundane stuff that can easily be automated and leaves you free to get on with owning boxes demonstrating risk using techniques that yaptest doesn't know about yet.
