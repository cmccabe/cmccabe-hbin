#!/bin/bash

rm -f ./hadoop-dist/target/hadoop-*-SNAPSHOT.tar.gz

time mvn package -e -Drequire.fuse -Drequire.snappy -Pnative -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true
