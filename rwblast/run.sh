#!/bin/bash

die() {
    echo $@
    exit 1
}

usage() {
    cat <<EOF
run: run the simple read test.

Note: this script requires you to be able to run perf as root.  I recommend
adding this to your /etc/sudoers file:
    Cmnd_Alias PERF = /usr/bin/perf
    cmccabe ALL=NOPASSWD: SETENV: PERF
Also comment "Defaults env_reset" if it's present.

-h:               this help message
-n <num-copies>:  number of copies of the file to read
-p <perf-op>:     perf operation(s) (default: stat, suggested: time, record)
EOF
}

num_copies=1
perf_op="stat"
while getopts  "f:hn:p:" flag; do
    case $flag in
    h) usage; exit 0;;
    n) num_copies=$OPTARG;;
    p) perf_op=$OPTARG;;
    *) echo; usage; exit 1;;
    esac
done

TMPSCRIPT=`mktemp -t rwblast.XXXXXXXXXX` || exit 1
trap "rm -rf ${TMPSCRIPT}; exit" INT TERM EXIT
rwblasts=`for i in $(seq -s ' ' -w 1 $num_copies); do echo -n "/rwblast-$i "; done`
echo "/h/bin/hadoop fs -cat $rwblasts > /dev/null" > $TMPSCRIPT \
    || die "failed to create $TMPSCRIPT"
chmod +x $TMPSCRIPT || die "failed to chmod $TMPSCRIPT"
orig_user=`whoami`
echo "** running $(cat $TMPSCRIPT) **"
if [ "x$perf_op" == "xtime" ]; then
    /usr/bin/time $TMPSCRIPT || die "$TMPSCRIPT failed"
else
    sudo -E perf ${perf_op} -a sudo -E -u $orig_user $TMPSCRIPT \
        || die "$TMPSCRIPT failed."
fi
