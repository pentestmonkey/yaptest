#!/bin/sh

# Check that required PERL modules are installed
echo
echo Checking required PERL modules are installed
echo ============================================
MISSING_MODULE=0
for MODULE in `cat external-perl-modules.txt`; do 
	echo -n "Checking for $MODULE ... "
	perl -M$MODULE -e '' >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo WARNING: Not Installed
		MISSING_MODULE=1
	else
		echo OK
	fi
done
echo

# Print advice about installing modules
if [ $MISSING_MODULE == 1 ]; then
	echo "Yaptest may not work correclty without the above PERL modules"
	echo "To install missing modules you have a few options:"
	echo
	echo "1: (Recommended) Use your OS package management tools to"
	echo "   search for then install the relevant packages."
	echo
	echo "   Gentoo: emerge --search template; emerge dev-perl/Template-Toolkit"
	echo "   FC6:    yum search template; yum install somepackage"
	echo "   Debian: apt-cache search template; apt-get install somepackage"
	echo
	echo "2: Use CPAN to install the relevant packages, e.g. as root"
	echo "   you'd run this to install Template::Toolkit:"
	echo 
	echo "   # perl -MCPAN -e shell"
	echo "   cpan> install Template::Toolkit\n"
	echo
	echo "3: Download the required module and install it manually"
	echo "   Search the CPAN modules at http://search.cpan.org/"
	echo
else
	echo "Good.  All required modules appear to be installed."
	echo
fi 

# Check external programs are present simply by looking for them in
# the path using the 'which' command
echo Checking that required external programs are installed
echo ======================================================
MISSING_PROG=0
for PROG in `cat external-programs.txt`; do
	echo -n "Checking for $PROG ... "
	PROGPATH=`which $PROG | grep -v '^no ' 2>/dev/null`
	if [ -z "$PROGPATH" ]; then
		MISSING_PROG=1
		echo WARNING: Not Installed
	else
		echo OK
	fi
done

# Advice on installing missing programs
if [ $MISSING_PROG == 1 ]; then
	echo
	echo "Yaptest may not work correctly without the above programs."
	echo "Then again if you don't want to run particular yaptest"
	echo "scripts then you may be able manage perfectly will without"
	echo "some of the programs above."
	echo
	echo "A list of links to the external programs is maintained at:"
	echo "http://pentestmonkey.net/projects/yaptest/yaptest-installation"
	echo
	echo "NB: This scripts only looks for external tools in your PATH."
	echo "    If /sbin or /usr/sbin is missing from your path some"
	echo "    tools may not be found."
	echo
else
	echo
	echo "Good.  All required external programs appear to be installed."
	echo
fi
