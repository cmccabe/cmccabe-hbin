#!/bin/bash

export HOSTS="htrace-csd-1.vpc.cloudera.com htrace-csd-2.vpc.cloudera.com htrace-csd-3.vpc.cloudera.com htrace-csd-4.vpc.cloudera.com"
#export HOSTS="htrace-csd-2.vpc.cloudera.com htrace-csd-3.vpc.cloudera.com htrace-csd-4.vpc.cloudera.com"
export HUSER="root"

die() {
    echo $@
    exit 1
}

[ "x${HPASS}" == "x" ] && die "you must set HPASS"

sync() {
    RPM_NAME="${1}"
    shift
    [ -e "${RPM_NAME}" ] || die "failed to find file ${RPM_NAME}"
    for h in $HOSTS; do
        echo "*** ${h}: installing ${RPM_NAME}"
        #rsync --rsh=`sshpass -p ${HPASS} ssh -l -u $HUSER` "${RPM_NAME}" "$h:~/"
        sshpass -p ${HPASS} ssh -o StrictHostKeyChecking=no "$HUSER@$h" "rpm -e 'htrace-htraced-*'"
        sshpass -p ${HPASS} rsync --progress -avz -e 'ssh -o StrictHostKeyChecking=no' "${RPM_NAME}" $HUSER@$h:~/r.rpm
        sshpass -p ${HPASS} ssh -o StrictHostKeyChecking=no "$HUSER@$h" "rpm -v -i --nodeps r.rpm" || die "failed to install rpm on $h"
    done
}

ACTION="${1}"
shift
case ${ACTION} in
    sync)
        sync "${@}"
        exit 0
        ;;
    "")
        exit 0
        ;;
    *)
        echo "unknown action ${ACTION}"
        ;;
esac
