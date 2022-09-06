#!/usr/bin/env bash

die() {
    echo $@
    exit 1
}

[[ $# -lt 1 ]] && die "Usage: $0 [component] [test]"
COMPONENT=$1
shift

FLAGS_TO_APPEND=""
while [[ $# -gt 0 ]]; do
    FLAGS_TO_APPEND="$FLAGS_TO_APPEND --tests ${1}"
    shift
done

if [[ -v OFFLINE ]]; then
    FLAGS_TO_APPEND="$FLAGS_TO_APPEND --offline"
fi

exec ./gradlew \
    :${COMPONENT}:test \
    -x :${COMPONENT}:checkstyleMain \
    -x :${COMPONENT}:checkstyleTest \
    -x :${COMPONENT}:spotbugsMain \
    -x :${COMPONENT}:spotbugsTest \
    ${FLAGS_TO_APPEND}
