#!/bin/sh

if [ $# != 3 ]; then
	echo "Usage: $0 bindir datadir"
	echo "e.g. $0 /usr/local/bin /usr/local/share/yaptest /usr/local/lib/site_perl"
	exit 0;
fi

BINDIR=$1
DATADIR=$2
PERLDIR=$3

mkdir -p -m 0755 $BINDIR $DATADIR $PERLDIR

echo "Installing program files to $BINDIR"
for FILE in `cat program-files.txt`; do 
	OK=`perl -c "$FILE" 2>&1 | grep 'syntax OK'`
	ISPERL=`echo $FILE | grep '\.pl$'`
	if [ -n "$ISPERL" ] && [ -z "$OK" ]; then
		echo "WARNING: PERL Syntax error in $FILE.  Installing anyway.";
	fi
	install -m 0755 -o root -g 0 $FILE $BINDIR
done

echo "Installing data files to $DATADIR"
for FILE in `cat data-files.txt`; do 
	install -m 0644 -o root -g 0 $FILE $DATADIR
done

echo "Installing PERL modules to $PERLDIR"
cd modules/yaptest
perl Makefile.PL
make && make install
cd ../..

echo "Installing config file to /etc/"
install -m 0644 -o root -g 0 yaptest.conf /etc/

