#!/bin/bash

# to copy and build on the master:
# ./doall.sh -u ~/hadoop1 && ./doall.sh -m 'cd hadoop1 && ~/cmccabe-hbin/mvn-make-tar.sh'

# to sync the built items from the master to the slaves:
# ./doall.sh -s 'rsync -avi c2018.halxg.cloudera.com:~/hadoop1/ ~/hadoop1'

die() {
    echo $1
    exit 1
}

usage() {
    cat <<EOF
$0: do hadoop testing on a cluster

-a [cmd]   run a command on all nodes
-h         this help message
-m [cmd]   run a command on the master node
-P         parallelize this operation
-s [cmd]   run a command on all nodes except the master
-u [dir]   upload a hadoop source directory to the master node
EOF
}

run_cmd() {
    fname="$1.para.txt"
    shift
    if [ $para -eq 0 ]; then
        $@
    else
        &> $fname $@ &
    fi
}

run_master() {
    echo "************************ master: $MASTER ********************"
    run_cmd $MASTER ssh $SSH_OPTS $MASTER $cmd
    [ $para -ne 0 ] && echo "[to $MASTER.para.txt]"
}

run_slaves() {
    for slave in $SLAVES; do
        echo "************************ slave: $slave ********************" $ret
        run_cmd $slave ssh $SSH_OPTS $slave $cmd
        [ $para -ne 0 ] && echo "[to $slave.para.txt]"
    done
}

upload_src_master() {
    [ $para -ne 0 ] && die "parallelism not support for upload to master.  -h for help."
    set -x
    rsync -e "ssh $SSH_OPTS" -avi --exclude '*.jar' \
--exclude '*.class' \
--exclude '.git' \
--exclude '*.tar.gz' \
$cmd $MASTER:$cmd
}

[ -v MASTER ] || die "you must set MASTER to the hostname of the master node"
[ -v SLAVES ] || die "you must set SLAVES to a whitespace-separated list of \
the hostnames of the slave nodes"
SSH_OPTS="-oStrictHostKeyChecking=no "

action="none"
para=0
while getopts  "a:hm:Ps:u:" flag; do
    case $flag in
    a) action="run_all"; cmd=$OPTARG;;
    h) usage; exit 0;;
    m) action="run_master"; cmd=$OPTARG;;
    P) para=1;;
    s) action="run_slaves"; cmd=$OPTARG;;
    u) action="upload_src_master"; cmd=$OPTARG;;
    *) usage; exit 1;;
esac
done
shift $((OPTIND-1))
[ $action = "none" ] && die "you must supply an action... -h for help."
if [ $para -eq 1 ]; then
    rm -f *.para.txt || die "failed to remove *.para.txt files"
fi
if [ $action = "run_all" ]; then
    run_master
    run_slaves
fi
if [ $action = "run_master" ]; then
    run_master
fi
if [ $action = "run_slaves" ]; then
    run_slaves
fi
if [ $action = "upload_src_master" ]; then
    upload_src_master
fi
wait
