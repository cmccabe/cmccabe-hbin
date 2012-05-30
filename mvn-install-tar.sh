#!/bin/bash

die() {
    echo $@
    exit 1
}

REMOTE=$1
[ -d "${HADOOP_HOME_BASE}" ] || die "can't find HADOOP_HOME_BASE directory"
res=./hadoop-dist/target/hadoop-*.tar.gz
if [ -f ${res} ]; then
    :
elif [ -f "../../${res}" ]; then
    res="../../${res}"
else
    die "can't find tar"
fi
rm -rf "${HADOOP_HOME_BASE}"
mkdir "${HADOOP_HOME_BASE}"
tar xvzf ${res} --strip-components=1 -C "${HADOOP_HOME_BASE}" || die "failed to untar"
