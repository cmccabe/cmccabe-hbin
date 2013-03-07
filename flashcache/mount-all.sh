#!/usr/bin/env bash

source "`dirname $0`/common.sh"

usage="you must supply an argument: flashcache or regular"
[ $# -lt 1 ] && die $usage
arg=$1
if [ $arg == "flashcache" ]; then
    fio_part_num=$FIO_FIRST_PART_NUM
    cache_num=$CACHE_FIRST_NUM
    set -x
    for drive in $CDRIVE_LETTERS; do
        mount /dev/mapper/cache${cache_num} /data/${cache_num}
        cache_num=$((cache_num+1))
    done
elif [ $arg == "regular" ]; then
    for drive in $CDRIVE_LETTERS; do
        mount /data/${cache_num}
    done
else
    die $usage
fi
