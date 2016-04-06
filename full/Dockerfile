FROM rathena-db:latest
ADD add .
EXPOSE 5121
EXPOSE 6121
EXPOSE 6900
CMD /etc/init.d/mysql start && ./athena-start start && /bin/sh
