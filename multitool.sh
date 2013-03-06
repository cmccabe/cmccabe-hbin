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
-A         abort on any failures (can't be used with -P)
-h         this help message
-I         introduce all the nodes to each other by making them ssh to 
           each other.
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
        rval=$?
        if [ $abort_on_fail -ne 0 ]; then
            [ $rval -ne 0 ] && die "command failed with error $rval"
        fi
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

run_introduce() {
    all="$MASTER $SLAVES"
    for a in $all; do
        for b in $all localhost 127.0.0.1 0.0.0.0; do
            #echo ssh $SSH_OPTS $a "ssh -oStrictHostKeyChecking=no $b echo $a:$b"
            ssh $SSH_OPTS $a "ssh -oStrictHostKeyChecking=no $b echo $a:$b" &
        done
    done
}

upload_src_master() {
    [ $para -ne 0 ] && die "parallelism not support for upload to master.  -h for help."
    set -x
    rsync -e "ssh $SSH_OPTS" -aviL --exclude '*.jar' \
--exclude '*.class' \
--exclude '.git' \
--exclude '*.tar.gz' \
$cmd $MASTER:$cmd
    if [ $abort_on_fail -ne 0 ]; then
        [ $rval -ne 0 ] && die "command failed with error $rval"
    fi
}

[ "x$MASTER" == "x" ] && die "you must set MASTER to the hostname of the master node"
[ "x$SLAVES" == "x" ] && die "you must set SLAVES to a whitespace-separated list of \
the hostnames of the slave nodes"
SSH_OPTS="-oStrictHostKeyChecking=no "

abort_on_fail=0
action="none"
para=0
while getopts  "Aa:hIm:Ps:u:" flag; do
    case $flag in
    A) abort_on_fail=1;;
    a) action="run_all"; cmd=$OPTARG;;
    h) usage; exit 0;;
    I) action="introduce";;
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
    [ $abort_on_fail -eq 1 ] && die "can't combine -A (abort on failures) and -P (parallelize)"
    rm -f *.para.txt || die "failed to remove *.para.txt files"
fi
if [ $action = "introduce" ]; then
    run_introduce
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
