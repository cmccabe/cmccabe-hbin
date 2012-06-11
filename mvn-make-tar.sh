#!/bin/bash

rm -f ./hadoop-dist/target/hadoop-*-SNAPSHOT.tar.gz

time mvn package -e -Pnative -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true
