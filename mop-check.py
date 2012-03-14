#!/usr/bin/env python
# mop-check - Tool to identify routers on the local LAN and paths to the Internet
# Copyright (C) 2012 pentestmonkey@pentestmonkey.net
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as 
# published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#
# This tool may be used for legal purposes only.  Users take full responsibility
# for any actions performed using this tool.  If these terms are not acceptable to 
# you, then do not use this tool.
# 
# You are encouraged to send comments, improvements or suggestions to
# me at pentestmonkey at pentestmonkey.net
#

from scapy.all import *
import sys
import os
from time import sleep
import signal
from optparse import OptionParser

parser = OptionParser(usage="Usage: %prog [ -I interface ] -f macs.txt\n\nIdentifies systems that respond to DEC MOP Remote Console probes.  Use this tool to identify cisco devices that can be connected to using the Linux moprc client (a bit like telnet):\napt-get install latd\nmoprc -v 00:11:22:33:44:55\n\nmacs.txt should contain a list of MAC addresses - it can be the output of arp-scan -l\n")
parser.add_option("-v", "--verbose", dest="verbose", action="store_true", default=False, help="Verbose output")
parser.add_option("-s", "--srcmac", dest="srcmac", default="22:44:66:88:aa:cc", help="Source MAC address for probes")
parser.add_option("-I", "--interface", dest="interface", default="eth0", help="Network interface to use")
parser.add_option("-f", "--macfil", dest="macfile", help="File containing MAC addresses")

(options, args) = parser.parse_args()

if not options.macfile:
	print "[E] No macs.txt specified.  -h for help."
	sys.exit(0)

version = "1.0"
print "mop-check v%s http://pentestmonkey.net/tools/mop-check" % version
print
print "[+] Using interface %s (-I to change)" % options.interface
print "[+] Using source MAC %s (-s to change)" % options.srcmac
macfh = open(options.macfile, 'r')
lines = map(lambda x: x.rstrip(), macfh.readlines())
macs = []
ipofmac = {}
for line in lines:
	m = re.search('([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2})', line)
	if m and m.group(1):
		ipofmac[m.group(1).upper()] = "UnknownIP"
		m = re.search('(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}).*?([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2})', line)
		if m and m.group(1) and m.group(2):
			ipofmac[m.group(2).upper()] = m.group(1)
		else:
			m = re.search('([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}).*?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})', line)
			if m and m.group(1) and m.group(2):
				ipofmac[m.group(1).upper()] = m.group(2)

macs = ipofmac.keys()

print "[+] Found %s MAC addresses in %s" % (len(macs), options.macfile)

if len(macs) == 0:
	print "[E] No MAC addresses found in %s" % options.macfile
	sys.exit(0)

def handler(signum, frame):
	vprint("Child process received signal %s.  Exiting." % signum)
	sys.exit(0)

def vprint(message):
	if options.verbose:
		print "[-] %s" % message

signal.signal(signal.SIGTERM, handler)
signal.signal(signal.SIGINT, handler)

def processreply(p):
	if p[Ether].dst == "22:44:66:88:aa:cc":
		print "[+] Recieved Reply From %s" % p[Ether].src
		if options.verbose:
			p.show()
	return False

# Build list of packets to send
seq = 0
packets = []
for mac in macs:
	packets.append({ 'packet': Ether(type=0x6002,src=options.srcmac,dst=mac)/"\x05\x00\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x02\x03\x04\x05\x06\x00\x00\x00\x01\x02\x03\x04\x05", 'seq': seq});
	seq = seq + 1

pid = os.fork()
if pid:
	# parent will send packets
	sleep(2) # give child time to start sniffer
	vprint("Parent processing sending packets...")
	for packet in packets:
		sendp(packet['packet'], verbose=0)
	vprint("Parent finished sending packets")
	sleep(2) # give child time to capture last reply
	vprint("Parent killing sniffer process")
	os.kill(pid, signal.SIGTERM)
	vprint("Parent reaping sniffer process")
	os.wait()
	vprint("Parent exiting")

	print "[+] Done"
	print
	sys.exit(0)
	
else:
	# child will sniff
	filter="ether host %s" % options.srcmac
	vprint("Child process sniffing on %s with filter '%s'" % (options.interface, filter))
	sniff(iface=options.interface, store = 0, filter=filter, prn=None, lfilter=lambda x: processreply(x))
