#!/bin/bash -e

# defaults
export VERSION="${VERSION:-master}"
export BUILDARGS=${BUILDARGS:-}

# optional rebuild with alternative version or buildargs
if [ "$VERSION" != "master" ] || [ -n "$BUILDARGS" ]; then
	echo "rebuilding ($VERSION:$BUILDARGS)"
	(git checkout $VERSION && ./configure $BUILDARGS && make clean server)
fi

# copy/install configuration files
cp -r /configs/* /rathena/conf/import/

# load sql into database
#
# @note: these may fail if resources conflict, but it shouldn't cause any issues
mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD < "/rathena/sql-files/main.sql" || echo "failed to (re)load main.sql"
mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD < "/rathena/sql-files/web.sql" || echo "failed to (re)load web.sql"
mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD < "/rathena/sql-files/roulette_default_data.sql" || echo "failed to (re)load roulette_default_data.sql"
mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD < "/rathena/sql-files/logs.sql" || echo "failed to (re)load lobs.sql"

# update server username and password (eg. id 1)
if [ -n "$SERVER_ACCOUNT" ] && [ -n "$SERVER_PASSWORD" ]; then
	echo "updating server account ($SERVER_ACCOUNT:$SERVER_PASSWORD)"
	mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD -e "update login set userid = \"$SERVER_ACCOUNT\", user_pass = md5(\"$SERVER_PASSWORD\") where account_id = 1;"
fi

# setup GM account (eg. id 2000000)
if [ -n "$GM_ACCOUNT" ] && [ -n "$GM_PASSWORD" ]; then
	echo "upserting gm account ($GM_ACCOUNT:$GM_PASSWORD)"
	mariadb $MARIADB_DATABASE -h$MARIADB_HOST -u$MARIADB_USER -p$MARIADB_PASSWORD -e "insert into login (account_id, userid, user_pass, sex, group_id) values (2000000, \"$GM_ACCOUNT\", md5(\"$GM_PASSWORD\"), \"M\", 99) on duplicate key update userid = \"$GM_USERNAME\", user_pass = \"$GM_PASSWORD\";"
fi
