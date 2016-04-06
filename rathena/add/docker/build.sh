#!/bin/bash -eux

# simple steps to configure and build rathena
./configure --enable-prere=$PRERE --enable-packetver=$PACKETVER
make clean
make server
