#!/bin/bash -eux

# exit if no docker exists
if ! which docker; then echo "docker required..." && exit 1; fi

# @temp: run all three builds then launch the final container
(cd rathena && docker build -t "rathena:latest" .)
(cd db && docker build -t "rathena-db:latest" .)
(cd full && docker build -t "rathena-full:latest" .)
export dcid=$(docker create -ti -p "5121:5121" -p "6121:6121" -p "6900:6900" rathena-full)
docker start $dcid

# @todo: ask for inputs to override defaults when building containers

# @todo: check for full vs demo to change behaivor

# @todo: start a database instance (more steps to come)
#db=$(docker create -ti rathenadb) docker start $db
