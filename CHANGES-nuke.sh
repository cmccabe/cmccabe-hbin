#!/bin/bash -x

#
# If there are any CHANGES.txt files which are marked as changed,
# run git-reset followed by git-checkout on them.
#

TFILE=/tmp/$$.changes.txt
git status | grep CHANGES.txt > $TFILE
if [ -s $TFILE ]; then
    sed --in-place 's/.*://' $TFILE
    xargs --arg-file=$TFILE -l git reset
    xargs --arg-file=$TFILE -l git checkout
fi
rm -f $TFILE
