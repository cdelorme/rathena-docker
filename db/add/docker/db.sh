#!/bin/bash -eux

# create user, database, and access rights to that database
mysql -u root --password="$ROOTPW" -e "create database $DBNAME;"
mysql -u root --password="$ROOTPW" -e "create user '$DBUSER'@'localhost' identified by '$DBPASS';"
mysql -u root --password="$ROOTPW" -e "grant select,insert,update,delete on \`$DBNAME\`.* to '$DBUSER'@'localhost';"

# rebuild item sql using convert tool
(cd /rathena/tools && ./convert_sql.pl --i=../db/re/item_db.txt --o=../sql-files/item_db_re.sql -t=re --m=item)

# load all mysql data files
(cd /rathena && for F in sql-files/*.sql; do mysql -u root --password="$ROOTPW" $DBNAME < $F; done)

# update server username and password
mysql $DBNAME -u root --password="$ROOTPW" -e "update \`login\` set \`userid\` = \"$SERVERUSER\", \`user_pass\` = md5(\"$SERVERPASS\") where \`account_id\` = 1;"
