#!/bin/bash

#
# Construct a CLASSPATH that contains all subdirectories of a given directory
# that contain jar files.
#

if [ $# -eq 0 ]; then
    TGT_DIRS=.
else
    TGT_DIRS=$@
fi
export CLASSPATH=$( 
    find ${TGT_DIRS} -noleaf -type f -name '*.jar' -printf ':%p' | cut -b 2- \
)
#export LD_LIBRARY_PATH=$( 
    #find ${TGT_DIR} -noleaf -name '*.so' -print0 | \
        #xargs -0 -l dirname | egrep '(target/native/target|.libs)' | \
        #xargs -l printf ':%s' | cut -b 2-
#)
