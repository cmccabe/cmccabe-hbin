#!/bin/bash

die() {
    echo $@
    exit 1
}

usage() {
    cat <<EOF
rmjar.sh: remove jars whose name matches a pattern

usage: rmjar.sh [options] [param]

options:
-h: this help message

param values:
all: remove all jars
cdh4: remove all jars except for cdh4 jars
apache3: remove all jars except for apache 3.0.0 jars
EOF
}

while getopts  "Aa:c:h" flag; do
    case $flag in
    h) usage; exit 0;;
    *) echo; usage; exit 1;;
    esac
done
shift $(($OPTIND - 1))

[ $# = 1 ] || die "must give exactly one argument.  -h for help."
ARG=$1
case $ARG in
all) find -name '*.jar' | xargs rm -f;;
apache3) find -name '*.jar' | egrep '[^A-Za-z]3.0.0-SNAPSHOT[^A-Za-z]' \
            | xargs -l rm -f
         find -name '*.jar' | egrep '[^A-Za-z]cdh4[^A-Za-z]' \
            | xargs -l rm -f;;
cdh4) find -name '*.jar' | egrep -v '[^A-Za-z]cdh4[^A-Za-z]' \
          | xargs -l rm -f;;
*) die "don't know how to handle $ARG.  -h for help.";;
esac

exit 0
