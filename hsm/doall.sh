#!/bin/bash

die() {
    echo $1
    exit 1
}

usage() {
    cat <<EOF
$0: do hadoop testing on a cluster

-a       run a command on all nodes
-h       this help message
-m       run a command on the master node
-s       run a command on all nodes except the master
-u       upload a hadoop source directory to the master node
EOF
}

run_master() {
    echo "************************ master: $MASTER ********************"
    ssh $MASTER $cmd
}

run_slaves() {
    for h in $SLAVES; do
        echo "************************ slave: $h ********************"
        ssh $h $cmd
    done
}

upload_src_master() {
    set -x
    rsync -avi --exclude '*.jar' \
--exclude '*.class' \
--exclude '.git' \
--exclude '*.tar.gz' \
$cmd $MASTER:$cmd
}

MASTER="c2018.halxg.cloudera.com"
SLAVES="\
c2004.halxg.cloudera.com \
c2005.halxg.cloudera.com \
c2006.halxg.cloudera.com \
c2007.halxg.cloudera.com \
c2008.halxg.cloudera.com \
c2009.halxg.cloudera.com \
c2010.halxg.cloudera.com \
c2011.halxg.cloudera.com \
c2012.halxg.cloudera.com \
c2013.halxg.cloudera.com \
c2014.halxg.cloudera.com \
c2015.halxg.cloudera.com \
c2016.halxg.cloudera.com \
c2017.halxg.cloudera.com \
"

action="none"
while getopts  "a:hm:s:u:" flag; do
    case $flag in
    a) action="run_all"; cmd=$OPTARG;;
    h) usage; exit 0;;
    m) action="run_master"; cmd=$OPTARG;;
    s) action="run_slaves"; cmd=$OPTARG;;
    u) action="upload_src_master"; cmd=$OPTARG;;
    *) usage; exit 1;;
esac
done
shift $((OPTIND-1))
[ $action = "none" ] && die "you must supply an action... -h for help."
if [ $action = "run_all" ]; then
    run_master
    run_slaves
    exit 0
fi
if [ $action = "run_master" ]; then
    run_master
    exit 0
fi
if [ $action = "run_slaves" ]; then
    run_slaves
    exit 0
fi
if [ $action = "upload_src_master" ]; then
    upload_src_master
    exit 0
fi
