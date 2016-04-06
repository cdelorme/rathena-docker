#!/bin/bash -eux

# simple steps to configure and build rathena
./configure --enable-prere=${PRERE:-no} --enable-packetver=${PACKETVER:-20151029}
make clean
make server
