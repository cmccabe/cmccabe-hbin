#!/usr/bin/env bash

die() {
    echo $@
    exit 1
}

usage() {
    cat <<EOF
git-cherry-pick-all.sh: cherry-pick a patch to multiple branches.
-c <commit>:    the commit to cherry-pick
-h:             this help message
-i:             interactive mode
-x:             use -x flag in git cherry-pick
EOF
}

yesno() {
    args=$1
    RESULT=2
    while [ $RESULT -eq 2 ]; do
        read -p "$args" choice
        case "$choice" in
            y|Y) RESULT=1;;
            n|N) RESULT=0;;
            *) echo "invalid; please enter y or n";;
        esac
    done
}

[ $# -lt 1 ] && die "you must specify the remote to pull from"
remote=$1

commit=""
flags=""
interactive=0
while getopts  "c:hix" flag; do
    case $flag in
    c) commit=$OPTARG;;
    h) usage; exit 0;;
    i) interactive=1;;
    x) flags="$flags -x";;
    *) usage; exit 1;;
    esac
    #echo "$flag" $OPTIND $OPTARG
done

[ x"$commit" == "x" ] && die "you must specify a commit with -c"

git branch | sed 's/\*//' > /tmp/$$
exec 4< /tmp/$$
while read branch <&4; do
    RESULT=1
    if [ $interactive -eq 1 ]; then
        yesno "would you like to cherry-pick to $branch? "
    fi
    if [ $RESULT -eq 1 ]; then
        git checkout $branch || die "failed to checkout $branch"
        git cherry-pick $flags $commit || die "failed to cherry-pick"
    fi
done
rm -f /tmp/$$
