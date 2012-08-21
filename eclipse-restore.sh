#!/bin/bash -ex

#
# Rebuild the eclipse stuff after in a hadoop/ directory after it's
# been clobbered
#
# NOTE: you may also have to right click on a few projects and do "Open
# Project" in Eclipse to get things back to normal.
#

die() {
    echo $@
    exit 1
}

P="`readlink -f .`"
if [ "x${P}" == "x/home/cmccabe/hadoop1" ]; then 
    W=/home/cmccabe/workspace
elif [ "x${P}" == "x/home/cmccabe/hadoop2" ]; then 
    W=/home/cmccabe/workspace2
else
    die "unknown directory '${P}'"
fi

mvn clean
mvn package -e -Pdist -Dtar -DskipTests -Dmaven.javadoc.skip=true
mvn -Declipse.workspace=${W} eclipse:configure-workspace
#mvn -DdownloadSources=true -DdownloadJavadocs=true eclipse:eclipse
cp -a hadoop-hdfs-project/hadoop-hdfs/target/webapps \
    hadoop-hdfs-project/hadoop-hdfs/target/classes/webapps
