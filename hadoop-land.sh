#!/usr/bin/env bash

die() {
    echo $1
    exit 1
}

usage() {
    cat <<EOF
$0: set up a hadoop jar running environment

-c [conf-dir]:     configuration directory
-h:                this help message
-I [install-dir]:  hdfs install directory
EOF
}

conf_dir=""
install_dir=""
while getopts  "c:hI:" flag; do
    case $flag in
    c) conf_dir=$OPTARG;;
    h) usage; exit 0;;
    I) install_dir=$OPTARG;;
    *) usage; exit 1;;
esac
done
shift $((OPTIND-1))

[ x"$conf_dir" == x ] && die "you must specify a conf dir.  -h for help."
[ -d "$conf_dir" ] || die "doesn't exist or not a directory: $conf_dir"
[ x"$install_dir" == x ] && die "you must specify an install dir.  -h for help."
[ -d "$install_dir" ] || die "doesn't exist or not a directory: $install_dir"

cpath_dirs="$install_dir/share/hadoop/common $install_dir/share/hadoop/hdfs"
export CLASSPATH=$( 
    find ${cpath_dirs} \
        -noleaf -type f -name '*.jar' -printf ':%p' | cut -b 2- \
)

export CLASSPATH="./:$conf_dir:$CLASSPATH"
libhadoop_so_path="$install_dir/lib/native/libhadoop.so"
[ -e "${libhadoop_so_path}" ] \
    || die "can't locate libhadoop.so at ${libhadoop_so_path}"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:$install_dir/lib/native"

# our log4j.properties has this line:
# log4j.appender.file.File=${hadoop.log.dir}/${hadoop.log.file}
# since we don't want to get overwhelmed by "can't open logfile" spew,
# set a valid path for this stuff.
export _JAVA_OPTIONS="-Dhadoop.log.dir=/tmp -Dhadoop.log.file=jlog"
