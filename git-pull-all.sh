#!/usr/bin/env bash

die() {
    echo $@
    exit 1
}

[ $# -lt 1 ] && die "you must specify the remote to pull from"
remote=$1

git branch | sed 's/\*//' > /tmp/$$
while read branch; do
    git checkout $branch || die "failed to checkout $branch"
    git pull --rebase $remote $branch || die "failed to rebase $branch"
done < /tmp/$$
rm -f /tmp/$$
