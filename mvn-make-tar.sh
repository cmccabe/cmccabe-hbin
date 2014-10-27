#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"

rm -f ./hadoop-dist/target/hadoop-*-SNAPSHOT.tar.gz

time mvn package -Drequire.fuse \
    -Pnative -Pdist -Dtar -DskipTests -Drequire.openssl -Dmaven.javadoc.skip=true "$@"
