#!/bin/bash

#
# Construct a CLASSPATH that contains all subdirectories of a given directory
# that contain jar files.
#

if [ $# -eq 0 ]; then
    TGT_DIR=.
else
    TGT_DIR=$1
fi
export CLASSPATH=$( find ${TGT_DIR} -noleaf -type f -name '*.jar' -printf ':%p' | cut -b 2- )
