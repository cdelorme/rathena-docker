FROM debian:buster

ARG version="master"
ARG packetver="20180621"
ARG prere="no"

WORKDIR /rathena
COPY . /compose

RUN apt update && \
	apt upgrade -yq && \
	apt install --no-install-recommends -yq git make gcc g++ zlib1g-dev ca-certificates libmariadb-dev libmariadb-dev-compat mariadb-server && \
	apt clean && \
	apt autoremove && \
	if [ ! -d /compose/rathena ]; then git clone https://github.com/rathena/rathena.git /rathena && git checkout ${version:-master}; else cp -r /compose/rathena /rathena; fi && \
	/etc/init.d/mysql start && \
	mysql -u root --password="default" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DELETE FROM mysql.user WHERE User=''; DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;" && \
	sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf && \
	mysql -u root --password="default" -e "create database ragnarok; create user 'rathena'@'%' identified by 'dbsecure'; grant select,insert,update,delete on ragnarok.* to 'rathena'@'%'; FLUSH PRIVILEGES;" && \
	(cd tools/ && ./convert_sql.pl --i=../db/re/item_db.txt --o=../sql-files/item_db_re.sql -t=re --m=item) && \
	for F in sql-files/*.sql; do mysql -u root --password="default" ragnarok < $F; done && \
	mysql ragnarok -u root --password="default" -e "update login set login.userid = 'char1', login.user_pass = md5('secret') where login.account_id = 1; insert into login (account_id, userid, user_pass, sex, email) values (2, 'char2', md5('secret'), 'S', 'athena@athena.com');" && \
	./configure --enable-prere=${prere:-no} --enable-packetver=${packetver:-20180621} && \
	make clean && \
	make server && \
	/etc/init.d/mysql stop

CMD /etc/init.d/mysql start && ./athena-start start && /bin/sh
