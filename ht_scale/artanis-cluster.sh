#!/bin/bash

export JPS="/opt/toolchain/sun-jdk-64bit-1.7.0.67/bin/jps"

export HOSTS="a2402.halxg.cloudera.com \
a2404.halxg.cloudera.com \
a2406.halxg.cloudera.com \
a2408.halxg.cloudera.com \
a2424.halxg.cloudera.com \
"

die() {
    echo "FAIL: "$@
    exit 1
}

run_or_die() {
    echo "$HOSTNAME: ${@}"
    "${@}" || die "${@}"
}

sync_host() {
    RPM_NAME="${1}"
    h="${2}"
    echo "*** ${h}: installing ${RPM_NAME}"
    rsync --progress -avz -e 'ssh -o StrictHostKeyChecking=no' "${RPM_NAME}" $h:~/r.rpm || die "rsync error"
    ssh -o StrictHostKeyChecking=no "$h" "sudo rpm -e 'htrace-htraced-*'"
    ssh -o StrictHostKeyChecking=no "$h" "sudo rpm -v -i --nodeps r.rpm" || die "failed to install rpm on $h"
}

sync() {
    RPM_NAME="${1}"
    shift
    [ -e "${RPM_NAME}" ] || die "failed to find file ${RPM_NAME}"
    for h in $HOSTS; do
        sync_host "${RPM_NAME}" "${h}" &>> "${h}.txt" &
    done
    wait
}

run_host() {
    h="${1}"
    shift
    echo "*** ${h}: ${@}"
    ssh -o StrictHostKeyChecking=no "$h" "${@}" || die "command failed"
}

run() {
    for h in $HOSTS; do
        run_host "${h}" "${@}" &>> "${h}.txt" &
    done
    wait
}

kill_jproc_host() {
    echo "*** kill_jproc_host ${@}"
    h="${1}"
    PATTERN="${2}"
    shift
    shift
    ssh -o StrictHostKeyChecking=no "$h" sudo pkill -f "java.*${PATTERN}"
}

kill_jproc() {
    PATTERN="${1}"
    shift
    for h in $HOSTS; do
        kill_jproc_host "${h}" "${PATTERN}" &>> "${h}.txt" &
    done
    wait
}

jps_host() {
    echo "*** jps ${@}"
    h="${1}"
    shift
    shift
    ssh -o StrictHostKeyChecking=no "$h" sudo "$JPS" || die "jps failed"
}

jps() {
    for h in $HOSTS; do
        jps_host "${h}" "${PATTERN}" &>> "${h}.txt" &
    done
    wait
}

node_echo_hash() {
    echo -n "hostname `hostname` hashes to $HOSTNAME_HASH.  Mod 10 is "
    echo $(($HOSTNAME_HASH % 10))
}

run_select() {
    echo "*** select ${@}"
    NUM="${1}"
    shift
    [ "${NUM}" -eq "${NUM}" ] &>/dev/null || die "select must be passed a number"
    if [ $(($HOSTNAME_HASH % $NUM)) -eq 0 ]; then
        echo "Node was selected."
        SRC="${BASH_SOURCE[0]}"
        exec "${SRC}" "${@}"
    else
        echo "Node was not selected."
    fi
}

node_create_random_local() {
    HOSTNAME_HASH=0x`hostname | md5sum | head -c 10`
    echo $(($HOSTNAME_HASH % 10))
    export TEST_DIR="/tmp/$$.$RANDOM.$RANDOM"
    mkdir -p "${TEST_DIR}" || die "failed to mkdir ${TEST_DIR}"
    trap "rm -rf ${TEST_DIR}" EXIT
    NUM_RANDOM_FILES=100
    echo "creating random local directory ${TEST_DIR}"
    for i in `seq 1 $NUM_RANDOM_FILES`; do
        head -c $(($RANDOM % 3000)) /dev/urandom | base64 > "${TEST_DIR}/$i"
    done
}

node_copyfromlocal() {
    node_create_random_local
    run_or_die hadoop fs -copyFromLocal "${TEST_DIR}" "/tmp/${HOSTNAME}.$RANDOM$RANDOM$RANDOM"
}

repeat() {
    TOTAL_REPEATS=$1
    shift
    [ "${TOTAL_REPEATS}" -eq "${TOTAL_REPEATS}" ] &>/dev/null || die "repeat must be passed a number"
    SRC="${BASH_SOURCE[0]}"
    for i in `seq 1 ${TOTAL_REPEATS}`; do
        echo "repeat $i of ${TOTAL_REPEATS} of $@"
        "${SRC}" "${@}" || die "${@} failed"
    done
}

map_host() {
    echo "*** map ${@}"
    h="${1}"
    CMD="${2}"
    SRC="${BASH_SOURCE[0]}"
    shift
    shift
    rsync --progress -avz -e 'ssh -o StrictHostKeyChecking=no' "${SRC}" $h:~/test.sh || die "rsync error"
    ssh -o StrictHostKeyChecking=no "$h" bash ~/test.sh "${CMD}" "${@}" || die "bash test.sh ${@} failed"
}

map() {
    CMD=${1}
    [ "x$CMD" == "x" ] && die "map requires at least one argument: \
the name of the command to run on each node."
    shift
    for h in $HOSTS; do
        map_host "${h}" "${CMD}" "${@}" &>> "${h}.txt" &
    done
    wait
}

copy_htraced_to_a2402() {
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-htraced/go/build/htraced \
        a2402.halxg.cloudera.com:/tmp/htraced
    run_or_die ssh -o StrictHostKeyChecking=no a2402.halxg.cloudera.com \
        sudo mv -f /tmp/htraced /usr/lib/htrace/bin/htraced
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-htraced/go/build/htracedTool \
        a2402.halxg.cloudera.com:/tmp/htracedTool
    run_or_die ssh -o StrictHostKeyChecking=no a2402.halxg.cloudera.com \
        sudo mv -f /tmp/htracedTool /usr/lib/htrace/bin/htracedTool
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-webapp/src/main/webapp/ \
        a2402.halxg.cloudera.com:/tmp/htracedWeb/
    run_or_die ssh -o StrictHostKeyChecking=no a2402.halxg.cloudera.com \
        sudo rsync -avi /tmp/htracedWeb/ /usr/lib/htrace/web/
}

# Kill all subprocesses on exit (doesn't work with kill -9, of course)
trap 'sleep & kill $(jobs -p) ; exit' INT EXIT

# Determine the hostname hash
HOSTNAME=`hostname`
HOSTNAME_HASH=0x`hostname | md5sum | head -c 10`

ACTION="${1}"
shift
if [[ ${ACTION} == node* ]]; then
    ${ACTION} "${@}"
    exit 0
fi

case ${ACTION} in
    sync)
        sync "${@}"
        exit 0
        ;;
    run)
        run "${@}"
        exit 0
        ;;
    kill_jproc)
        kill_jproc "${@}"
        exit 0
        ;;
    jps)
        jps "${@}"
        exit 0
        ;;
    repeat)
        repeat "${@}"
        exit 0
        ;;
    map)
        map "${@}"
        exit 0
        ;;
    select)
        run_select "${@}"
        exit 0
        ;;
    copy_htraced_to_a2402)
        copy_htraced_to_a2402 "${@}"
        exit 0
        ;;
    "")
        exit 0
        ;;
    *)
        cat <<EOF
artanis-cluster.sh: unknown action ${ACTION}

Script results are appended to files-- one per host.
Search for the string 'FAIL' to identify failures.

Known actions:
sync [htrace-rpm]: sync the given htrace RPM to the cluster nodes.
run [command]: run the given command on all nodes.
kill_jproc [pattern]: kill java processes matching the given pattern on all nodes.
jps: show the java processes running on all nodes by running jps.
repeat [N] [command]: repeat the following script command N times.
map [command]: run the map command on each host in the cluster.
select [num] [command]: select 1 / num nodes to run the given command.
EOF
        exit 0
        ;;
esac
