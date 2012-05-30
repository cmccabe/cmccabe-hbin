#!/bin/bash

rm -f ./hadoop-dist/target/hadoop-*-SNAPSHOT.tar.gz

time mvn package -e -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true
