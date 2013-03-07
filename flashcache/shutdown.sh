
#!/usr/bin/env bash

source "`dirname $0`/common.sh"

set -x
cache_num=$CACHE_FIRST_NUM
fio_part_num=$FIO_FIRST_PART_NUM
for drive in $CDRIVE_LETTERS; do
    if [ -e /dev/mapper/cache${cache_num} ]; then
        dmsetup remove /dev/mapper/cache${cache_num}
        "$FC_UTILS/flashcache_destroy" /dev/fioa${fio_part_num}
    fi
    cache_num=$((cache_num+1))
    fio_part_num=$((fio_part_num+1))
done
