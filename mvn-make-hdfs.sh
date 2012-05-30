#!/bin/bash

die() {
    echo $@
    exit 1
}

D="`pwd`"
D="`basename \"${D}\"`"
[ "x${D}" == "xhadoop-hdfs" ] \
    || die "this script must be run from the hadoop-hdfs directory"
mvn install -Pdist -DskipTests -Dmaven.javadoc.skip=true || die "mvn failed"
cp target/hadoop-hdfs-0.24.0-SNAPSHOT.jar \
    ${HADOOP_HOME_BASE}/share/hadoop/hdfs/hadoop-hdfs-0.24.0-SNAPSHOT.jar  \
        || die "cp failed"
