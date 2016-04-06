FROM debian:jessie
ENV CONFIG_ARGS $CONFIG_ARGS
RUN apt-get update && apt-get upgrade && apt-get install -yq git make gcc libmysqlclient-dev zlib1g-dev libpcre3-dev
RUN git clone https://github.com/rathena/rathena.git /rathena
WORKDIR /rathena
ADD add .
RUN ./docker/build.sh
