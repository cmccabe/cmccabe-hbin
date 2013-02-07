#!/bin/bash

rm -f ./hadoop-dist/target/hadoop-*-SNAPSHOT.tar.gz

time mvn package -Drequire.fuse -Drequire.snappy -Drequire.libwebhdfs -Pnative -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true "$@"
