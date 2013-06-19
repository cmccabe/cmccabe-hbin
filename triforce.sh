#!/usr/bin/env bash

die() {
    echo $@
    exit 1
}

BRANCHES="trunk branch-2.1-beta branch-2"
REMOTE=apache
GIT=git

usage() {
    cat <<EOF
triforce: automates the process of generating patches for several svn branches from git

You must be in a git repo when running this.  The HEAD commit will be treated as the change which has to be cherry-picked into several other branches.

-b [branches]: default $BRANCHES
-h: this help message
-r [remote]: default $REMOTE
-n: dry-run
EOF
}

while getopts  "b:hnr:" flag; do
    case $flag in
    b)  BRANCHES=$OPTARG;;
    h) usage; exit 0;;
    n) GIT="echo git";;
    r) REMOTE=$OPTARG;;
    *) usage; exit 1;;
    esac
    #echo "$flag" $OPTIND $OPTARG
done

${GIT} fetch ${REMOTE} || die "git fetch failed"
rm -f ./*.patch
HEAD_COMMIT=`git rev-parse HEAD`
CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
echo "** cherry-picking commit $HEAD_COMMIT into each branch **"
for branch in $BRANCHES; do
    echo "*** branch ${branch} ***"
    ${GIT} checkout -b ${branch}-golden --track ${REMOTE}/${branch} || die "git checkout failed"
    ${GIT} cherry-pick -x $HEAD_COMMIT || die "git cherry-pick $HEAD_COMMIT failed"
    ${GIT} format-patch --stdout HEAD^ > ./$branch.patch
    ${GIT} checkout ${CUR_BRANCH} || die "failed to check out ${CUR_BRANCH}"
    ${GIT} branch -D "${branch}-golden"
done

echo -n "*** patch files generated: "
for branch in $BRANCHES; do
    echo -n "${branch}.patch "
done
echo
