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
-s <size>:        If supplied, the file will be truncated to this size before 
                  being uploaded.  (This can be used to increase the size too.)
EOF
}

file_name=""
num_copies=1
size=0
while getopts  "f:hn:s:" flag; do
    case $flag in
    f) file_name=$OPTARG;;
    h) usage; exit 0;;
    n) num_copies=$OPTARG;;
    s) size=$OPTARG;;
    *) echo; usage; exit 1;;
    esac
done

[ "x$file_name" == "x" ] && die "you must give a file name.  -h for help."

if [ $size -ne 0 ]; then
    truncate -s $size $file_name || die "truncate failed."
fi

for i in `seq -w 1 $num_copies`; do
    /h/bin/hadoop fs -copyFromLocal "$file_name" "/rwblast-$i" \
        || die "copyFromLocal failed."
done
