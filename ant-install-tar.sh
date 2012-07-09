#!/bin/bash

die() {
    echo $@
    exit 1
}

[ -d "${HADOOP_HOME_BASE}" ] || die "can't find HADOOP_HOME_BASE directory"
#res=./build/hadoop-1.1.0-SNAPSHOT-amd64-bin.tar.gz
if [ -e ./build/hadoop-*SNAPSHOT-bin.tar.gz ]; then
    res=./build/hadoop-*SNAPSHOT-bin.tar.gz
elif [ -e ./build/hadoop-*bin.tar.gz ]; then
    res=./build/hadoop-*bin.tar.gz
else
    res=./build/hadoop-*.tar.gz
fi
[ -f ${res} ] || die "can't find tar"

rm -rf "${HADOOP_HOME_BASE}"
mkdir "${HADOOP_HOME_BASE}"
tar xvzf ${res} --strip-components=1 -C "${HADOOP_HOME_BASE}" || die "failed to untar"

# symlink stuff in bin to sbin so that I don't have to remember what was moved
mkdir -p ${HADOOP_HOME_BASE}/sbin
pushd ${HADOOP_HOME_BASE}/bin
for f in *; do
    ln -s `readlink -f $f` ../sbin/$f
done
popd &> /dev/null

# make binaries executable
chmod +x ${HADOOP_HOME_BASE}/bin/*
