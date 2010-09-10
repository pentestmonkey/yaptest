#!/bin/sh

if [ $# != 2 ]; then
	echo "Usage: $0 yaptest_template.sql { osx | linux }"
	exit 0;
fi

YAPTEST_TEMPLATE_SQL=$1
PLATFORM=$2

if [ "$PLATFORM" = "osx" ]; then
	echo "Configuring for OSX"
	YAPTEST_TEMPLATE_NAME=yaptest_template
	EXISTING_DATABASE=template1
	PSQL=psql81
	export PATH=$PATH:/opt/local/bin:/opt/local/lib/postgresql80/bin  # needed on mac for createuser, createdb and dropdb
	which $PSQL
	createuser -a -d postgres # needed to make sure the postgres user exists on mac - should exist elsewhere
else
	echo "Configuring for Linux"
	YAPTEST_TEMPLATE_NAME=yaptest_template
	EXISTING_DATABASE=template1
	PSQL=psql   # change to psql8 on mac or symlink psql -> psql8
fi

echo "update pg_database set datistemplate = 'f', datallowconn = 't' where datname = '"$YAPTEST_TEMPLATE_NAME"';" | $PSQL $EXISTING_DATABASE

dropdb $YAPTEST_TEMPLATE_NAME
echo "DROP USER yaptest_user;" | $PSQL $EXISTING_DATABASE

createdb -E UNICODE $YAPTEST_TEMPLATE_NAME

# In order to create databases we need to do things slightly
# differently on postgres 8.2+
PGVERSION82=`$PSQL -U postgres template1 -c 'SELECT version()' | grep 'PostgreSQL 8.[23456789]'`
if [ -z "$PGVERSION82" ]; then
	echo "CREATE USER yaptest_user;" | $PSQL $YAPTEST_TEMPLATE_NAME
	echo "UPDATE pg_shadow SET usecreatedb = 't' WHERE usename = 'yaptest_user';" | $PSQL $YAPTEST_TEMPLATE_NAME
else
	echo "CREATE USER yaptest_user CREATEDB ;" | $PSQL $YAPTEST_TEMPLATE_NAME
fi
cat $YAPTEST_TEMPLATE_SQL | $PSQL $YAPTEST_TEMPLATE_NAME

echo "UPDATE pg_database SET datistemplate = 't', datallowconn = 't' WHERE datname = '"$YAPTEST_TEMPLATE_NAME"';" | $PSQL $YAPTEST_TEMPLATE_NAME

