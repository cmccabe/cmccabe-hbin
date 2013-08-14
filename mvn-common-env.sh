#!/usr/bin/env bash

# Add the correct version of protoc to the front of the PATH.
if grep -q '<protocVersion>2.5.0</protocVersion>' ./hadoop-hdfs-project/hadoop-hdfs/pom.xml; then
    PROTOBUF_2_5="${PROTOBUF_2_5:-/opt/protobuf-2.5/bin}"
    PATH="$PROTOBUF_2_5:$PATH"
else
    PROTOBUF_2_4="${PROTOBUF_2_4:-/opt/protobuf-2.4/bin}"
    PATH="$PROTOBUF_2_4:$PATH"
fi
