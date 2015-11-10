#!/bin/bash

export JPS="/usr/java/jdk1.7.0_67-cloudera/bin/jps"

export HOSTS="a1008.halxg.cloudera.com \
c1604.halxg.cloudera.com \
a1009.halxg.cloudera.com \
a1010.halxg.cloudera.com \
a1012.halxg.cloudera.com \
a1022.halxg.cloudera.com \
a1105.halxg.cloudera.com \
a1106.halxg.cloudera.com \
a1107.halxg.cloudera.com \
a1108.halxg.cloudera.com \
a1109.halxg.cloudera.com \
a1110.halxg.cloudera.com \
a1111.halxg.cloudera.com \
a1112.halxg.cloudera.com \
a1113.halxg.cloudera.com \
a1114.halxg.cloudera.com \
a1115.halxg.cloudera.com \
a1116.halxg.cloudera.com \
a1117.halxg.cloudera.com \
a1118.halxg.cloudera.com \
a1119.halxg.cloudera.com \
a1120.halxg.cloudera.com \
a1121.halxg.cloudera.com \
a1123.halxg.cloudera.com \
a1124.halxg.cloudera.com \
a1125.halxg.cloudera.com \
a1126.halxg.cloudera.com \
a1127.halxg.cloudera.com \
a1129.halxg.cloudera.com \
a1130.halxg.cloudera.com \
a1131.halxg.cloudera.com \
a1132.halxg.cloudera.com \
a1133.halxg.cloudera.com \
a1134.halxg.cloudera.com \
a1135.halxg.cloudera.com \
a1136.halxg.cloudera.com \
a1137.halxg.cloudera.com \
a1138.halxg.cloudera.com \
a1205.halxg.cloudera.com \
a1308.halxg.cloudera.com \
a1309.halxg.cloudera.com \
a1310.halxg.cloudera.com \
a1312.halxg.cloudera.com \
a1314.halxg.cloudera.com \
a1315.halxg.cloudera.com \
a1316.halxg.cloudera.com \
a1317.halxg.cloudera.com \
a1318.halxg.cloudera.com \
a1319.halxg.cloudera.com \
a1320.halxg.cloudera.com \
a1321.halxg.cloudera.com \
a1323.halxg.cloudera.com \
a1324.halxg.cloudera.com \
a1325.halxg.cloudera.com \
a1326.halxg.cloudera.com \
a1327.halxg.cloudera.com \
a1328.halxg.cloudera.com \
a1329.halxg.cloudera.com \
a1330.halxg.cloudera.com \
a1331.halxg.cloudera.com \
a1332.halxg.cloudera.com \
a1333.halxg.cloudera.com \
a1334.halxg.cloudera.com \
a1335.halxg.cloudera.com \
a1336.halxg.cloudera.com \
a1337.halxg.cloudera.com \
a1338.halxg.cloudera.com \
a1405.halxg.cloudera.com \
a1406.halxg.cloudera.com \
a1407.halxg.cloudera.com \
a1408.halxg.cloudera.com \
a1409.halxg.cloudera.com \
a1410.halxg.cloudera.com \
a1411.halxg.cloudera.com \
a1412.halxg.cloudera.com \
a1413.halxg.cloudera.com \
a1414.halxg.cloudera.com \
a1415.halxg.cloudera.com \
a1416.halxg.cloudera.com \
a1417.halxg.cloudera.com \
a1418.halxg.cloudera.com \
a1419.halxg.cloudera.com \
a1420.halxg.cloudera.com \
a1421.halxg.cloudera.com \
a1422.halxg.cloudera.com \
a1423.halxg.cloudera.com \
a1424.halxg.cloudera.com \
a1425.halxg.cloudera.com \
a1426.halxg.cloudera.com \
a1428.halxg.cloudera.com \
a1429.halxg.cloudera.com \
a1430.halxg.cloudera.com \
a1431.halxg.cloudera.com \
a1432.halxg.cloudera.com \
a1433.halxg.cloudera.com \
a1434.halxg.cloudera.com \
a1435.halxg.cloudera.com \
a1436.halxg.cloudera.com \
a1437.halxg.cloudera.com \
a1438.halxg.cloudera.com \
a1515.halxg.cloudera.com \
a1516.halxg.cloudera.com \
a1517.halxg.cloudera.com \
a1518.halxg.cloudera.com \
a1519.halxg.cloudera.com \
a1520.halxg.cloudera.com \
a1521.halxg.cloudera.com \
a1522.halxg.cloudera.com \
a1523.halxg.cloudera.com \
a1524.halxg.cloudera.com \
a1525.halxg.cloudera.com \
a1526.halxg.cloudera.com \
a1527.halxg.cloudera.com \
a1529.halxg.cloudera.com \
a1530.halxg.cloudera.com \
a1531.halxg.cloudera.com \
a1532.halxg.cloudera.com \
a1533.halxg.cloudera.com \
a1534.halxg.cloudera.com \
a1535.halxg.cloudera.com \
a1536.halxg.cloudera.com \
a1537.halxg.cloudera.com \
a1538.halxg.cloudera.com \
a1711.halxg.cloudera.com \
a1724.halxg.cloudera.com \
a1821.halxg.cloudera.com \
a1822.halxg.cloudera.com \
a1823.halxg.cloudera.com \
a1909.halxg.cloudera.com \
a1910.halxg.cloudera.com \
a1911.halxg.cloudera.com \
a1912.halxg.cloudera.com \
a1913.halxg.cloudera.com \
a1914.halxg.cloudera.com \
a1915.halxg.cloudera.com \
a1916.halxg.cloudera.com \
a1917.halxg.cloudera.com \
a1918.halxg.cloudera.com \
a1924.halxg.cloudera.com \
a1925.halxg.cloudera.com \
a1926.halxg.cloudera.com \
a1927.halxg.cloudera.com \
a1928.halxg.cloudera.com \
a2004.halxg.cloudera.com \
a2005.halxg.cloudera.com \
a2006.halxg.cloudera.com \
a2007.halxg.cloudera.com \
a2008.halxg.cloudera.com \
a2009.halxg.cloudera.com \
a2010.halxg.cloudera.com \
a2011.halxg.cloudera.com \
a2012.halxg.cloudera.com \
a2013.halxg.cloudera.com \
a2014.halxg.cloudera.com \
a2015.halxg.cloudera.com \
a2016.halxg.cloudera.com \
a2017.halxg.cloudera.com \
a2018.halxg.cloudera.com \
a2019.halxg.cloudera.com \
a2020.halxg.cloudera.com \
a2021.halxg.cloudera.com \
a2023.halxg.cloudera.com \
a2024.halxg.cloudera.com \
a2027.halxg.cloudera.com \
a2029.halxg.cloudera.com \
a2030.halxg.cloudera.com \
a2031.halxg.cloudera.com \
a2032.halxg.cloudera.com \
a2033.halxg.cloudera.com \
a2107.halxg.cloudera.com \
a2125.halxg.cloudera.com \
a2126.halxg.cloudera.com \
a2127.halxg.cloudera.com \
a2128.halxg.cloudera.com \
a2129.halxg.cloudera.com \
a2220.halxg.cloudera.com \
a2221.halxg.cloudera.com \
a2222.halxg.cloudera.com \
a2223.halxg.cloudera.com \
a2319.halxg.cloudera.com \
a2320.halxg.cloudera.com \
a2321.halxg.cloudera.com \
a2333.halxg.cloudera.com \
c1605.halxg.cloudera.com \
c1606.halxg.cloudera.com \
c1607.halxg.cloudera.com \
c1608.halxg.cloudera.com \
c1609.halxg.cloudera.com \
c1610.halxg.cloudera.com \
c1611.halxg.cloudera.com \
c1612.halxg.cloudera.com \
c1613.halxg.cloudera.com \
c1614.halxg.cloudera.com \
c1615.halxg.cloudera.com \
c1616.halxg.cloudera.com \
c1617.halxg.cloudera.com \
c1618.halxg.cloudera.com \
c1619.halxg.cloudera.com \
c1620.halxg.cloudera.com \
c1621.halxg.cloudera.com \
c1622.halxg.cloudera.com \
c1623.halxg.cloudera.com \
c1624.halxg.cloudera.com \
c1625.halxg.cloudera.com \
c1626.halxg.cloudera.com \
c1627.halxg.cloudera.com \
c1628.halxg.cloudera.com \
c1629.halxg.cloudera.com \
c1630.halxg.cloudera.com \
c1631.halxg.cloudera.com \
c1632.halxg.cloudera.com \
c1633.halxg.cloudera.com \
c1717.halxg.cloudera.com \
c1718.halxg.cloudera.com \
c1719.halxg.cloudera.com \
c1720.halxg.cloudera.com \
c1721.halxg.cloudera.com \
c1723.halxg.cloudera.com \
c1725.halxg.cloudera.com \
c1726.halxg.cloudera.com \
c1727.halxg.cloudera.com \
c1728.halxg.cloudera.com \
c1730.halxg.cloudera.com \
c1731.halxg.cloudera.com \
c1732.halxg.cloudera.com \
c1804.halxg.cloudera.com \
c1805.halxg.cloudera.com \
c1806.halxg.cloudera.com \
c1807.halxg.cloudera.com \
c1808.halxg.cloudera.com \
c1809.halxg.cloudera.com \
c1810.halxg.cloudera.com \
c1811.halxg.cloudera.com \
c1812.halxg.cloudera.com \
c1813.halxg.cloudera.com \
c1814.halxg.cloudera.com \
c1815.halxg.cloudera.com \
c1816.halxg.cloudera.com \
c1817.halxg.cloudera.com \
c1818.halxg.cloudera.com \
c1819.halxg.cloudera.com \
c1820.halxg.cloudera.com \
c1821.halxg.cloudera.com \
c1822.halxg.cloudera.com \
c1823.halxg.cloudera.com \
c1824.halxg.cloudera.com \
c1825.halxg.cloudera.com \
c1826.halxg.cloudera.com \
c1827.halxg.cloudera.com \
c1830.halxg.cloudera.com \
c1831.halxg.cloudera.com \
c1832.halxg.cloudera.com \
c1833.halxg.cloudera.com \
c1905.halxg.cloudera.com \
c1911.halxg.cloudera.com \
c2314.halxg.cloudera.com \
c2316.halxg.cloudera.com \
c2318.halxg.cloudera.com \
c2320.halxg.cloudera.com \
c2322.halxg.cloudera.com \
c2324.halxg.cloudera.com \
c2326.halxg.cloudera.com \
c2328.halxg.cloudera.com \
c2402.halxg.cloudera.com \
c2404.halxg.cloudera.com \
c2406.halxg.cloudera.com \
c2408.halxg.cloudera.com \
c2410.halxg.cloudera.com \
c2412.halxg.cloudera.com \
c2414.halxg.cloudera.com \
c2416.halxg.cloudera.com \
c2418.halxg.cloudera.com \
c2420.halxg.cloudera.com \
c2422.halxg.cloudera.com \
c2424.halxg.cloudera.com \
c2426.halxg.cloudera.com \
c2428.halxg.cloudera.com \
c2430.halxg.cloudera.com \
c2432.halxg.cloudera.com \
c2434.halxg.cloudera.com \
c2436.halxg.cloudera.com \
c2438.halxg.cloudera.com \
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

copy_htraced_to_c2424() {
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-htraced/go/build/htraced \
        c2424.halxg.cloudera.com:/tmp/htraced
    run_or_die ssh -o StrictHostKeyChecking=no c2424.halxg.cloudera.com \
        sudo mv -f /tmp/htraced /usr/lib/htrace/bin/htraced
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-htraced/go/build/htracedTool \
        c2424.halxg.cloudera.com:/tmp/htracedTool
    run_or_die ssh -o StrictHostKeyChecking=no c2424.halxg.cloudera.com \
        sudo mv -f /tmp/htracedTool /usr/lib/htrace/bin/htracedTool
    run_or_die rsync -avi --delete \
        /home/cmccabe/cdh/repos/cdh5/htrace/htrace-webapp/src/main/webapp/ \
        c2424.halxg.cloudera.com:/tmp/htracedWeb/
    run_or_die ssh -o StrictHostKeyChecking=no c2424.halxg.cloudera.com \
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
    copy_htraced_to_c2424)
        copy_htraced_to_c2424 "${@}"
        exit 0
        ;;
    "")
        exit 0
        ;;
    *)
        cat <<EOF
bolt300-test-cluster.sh: unknown action ${ACTION}

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
