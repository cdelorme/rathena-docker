FROM rathena:latest
ENV ROOTPW ${ROOTPW:-default}
ENV DBNAME ${DBNAME:-ragnarok}
ENV DBUSER ${DBUSER:-rathena}
ENV DBPASS ${DBPASS:-default}
ENV SERVERUSER ${SERVERUSER:-server}
ENV SERVERPASS ${SERVERPASS:-default}
ADD add .
RUN (echo "mysql-server mysql-server/root_password password $ROOTPW" | debconf-set-selections) && (echo "mysql-server mysql-server/root_password_again password $ROOTPW" | debconf-set-selections) && apt-get install -yq mysql-server libmysqlclient-dev
EXPOSE 3306
RUN /etc/init.d/mysql start && mysql -u root --password="$ROOTPW" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" && mysql -u root --password="$ROOTPW" -e "DELETE FROM mysql.user WHERE User='';" && mysql -u root --password="$ROOTPW" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';" && mysql -u root --password="$ROOTPW" -e "FLUSH PRIVILEGES;"
RUN /etc/init.d/mysql start && ./docker/db.sh
CMD /etc/init.d/mysql start && /bin/sh
