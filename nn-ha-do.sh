#!/bin/bash

die() {
    echo $@
    exit 1
}

[ $# -lt 1 ] && die "you must supply an HA node to do the command as."
HA=$1
shift
PREV_HADOOP_CONF_DIR="$HADOOP_CONF_DIR"
[ -d "$PREV_HADOOP_CONF_DIR" ] || die "can't find \$HADOOP_CONF_DIR=$HADOOP_CONF_DIR"
source $PREV_HADOOP_CONF_DIR/$HA/hadoop-env.sh

# now HADOOP_CONF_DIR is set to $PREV_HADOOP_CONF_DIR/$HA, and the other shell
# variables are set accordingly.
"$@"
