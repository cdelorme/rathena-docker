FROM debian:jessie

# configurable settings with sane defaults
ENV prere ${prere:-no}
ENV packetver ${packetver:-20151029}
ENV version ${version:-b6abe3fcbf8aaf8b010818349f02676c86acbe60}

# install dependent packages, secure mysql, and download rathena source
RUN (echo "mysql-server mysql-server/root_password password default" | debconf-set-selections) && (echo "mysql-server mysql-server/root_password_again password default" | debconf-set-selections) && apt-get update && apt-get upgrade && apt-get install --no-install-recommends -yq git make gcc libmysqlclient-dev zlib1g-dev libpcre3-dev mysql-server libmysqlclient-dev ca-certificates
RUN /etc/init.d/mysql start && mysql -u root --password="default" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1'); DELETE FROM mysql.user WHERE User=''; DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'; FLUSH PRIVILEGES;"
RUN git clone https://github.com/rathena/rathena.git /rathena && cd /rathena && git checkout $version

# prepare workspace, update and load sql, then build the server components
WORKDIR /rathena
ADD rathena .
RUN /etc/init.d/mysql start && mysql -u root --password="default" -e "create database ragnarok; create user 'rathena'@'%' identified by 'dbsecure'; grant select,insert,update,delete on ragnarok.* to 'rathena'@'%'; FLUSH PRIVILEGES;" && (cd /rathena && for F in sql-files/*.sql; do mysql -u root --password="default" ragnarok < $F; done) && mysql ragnarok -u root --password="default" -e "update login set login.userid = \"server\", login.user_pass = md5(\"secret\") where login.account_id = 1;"
RUN ./configure --enable-prere=$prere --enable-packetver=$packetver && make clean && make server

# set default create/start command to execute for fast stand-alone deployment
CMD /etc/init.d/mysql start && ./athena-start start && /bin/sh
