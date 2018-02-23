#!/usr/bin/env bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [[ $# -lt 1 || $1 == "-h" || $1 == "--help" ]]; then
    cat <<EOF
$0: checks if the given set of hosts is reachable on port 22.

usage:
    $0 [flags] [host1,host2,...]

flags:
    -h|--help       This help message

environment variables:
    CHECK_INTERVAL  The minimum interval in seconds to check each host at.
EOF
    exit 0
fi

CHECK_INTERVAL=${CHECK_INTERVAL:-5}
hosts="$@"

ping_host() {
    host="$1"
    while true; do
        now=$(date +'%s')
        end=$(( now + CHECK_INTERVAL))
        timeout 1 bash -c "cat < /dev/null > /dev/tcp/$host/22" &> /dev/null
        [[ $? -eq 0 ]] || echo "Failed to connect to port 22 on $host"
        now=$(date +'%s')
        rem=$((end-now))
        [[ $rem -gt 0 ]] && sleep -- $rem
    done
}

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
for host in $hosts; do
    ping_host $host &
done

wait
