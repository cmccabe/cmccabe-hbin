#!/usr/bin/env bash

source "`dirname $0`/common.sh"

set -x
fio_part_num=$FIO_FIRST_PART_NUM
cache_num=$CACHE_FIRST_NUM
#-m 4096 \
for drive in $CDRIVE_LETTERS; do
    "$FC_UTILS/flashcache_create" -v -p back \
        -b 4096 \
        cache${cache_num} /dev/fioa${fio_part_num} /dev/sd${drive}1
    fio_part_num=$((fio_part_num+1))
    cache_num=$((cache_num+1))
done
