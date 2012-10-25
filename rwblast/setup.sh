#!/bin/bash

die() {
    echo $@
    exit 1
}

usage() {
    cat <<EOF
setup: set up the DN files for rwblast
-f <file-name>:   file to use as source
-h:               this help message
-n <num-copies>:  number of copies of that file to make
EOF
}

file_name=""
num_copies=20
while getopts  "f:hn:" flag; do
    case $flag in
    f) file_name=$OPTARG;;
    h) usage; exit 0;;
    n) num_copies=$OPTARG;;
    *) echo; usage; exit 1;;
    esac
done

[ "x$file_name" == "x" ] && die "you must give a file name.  -h for help."

for i in `seq -w 0 $num_copies`; do
    /h/bin/hadoop fs -copyFromLocal "$file_name" "/rwblast-$i" \
        || die "copyFromLocal failed."
done
