#!/usr/bin/env bash

ALL=0
DRY_RUN=0

die() {
    echo $@
    exit 1
}

gradle_base_command() {
    echo "./gradlew --offline"
}

gradle_submodule_arguments() {
    local SUBMODULE=$1
    echo ":${SUBMODULE}:test \
        -x :${SUBMODULE}:checkstyleMain \
        -x :${SUBMODULE}:checkstyleTest \
        -x :${SUBMODULE}:spotbugsMain \
        -x :${SUBMODULE}:spotbugsTest"
}

gradle_test_arguments() {
    RESULT=""
    for ARGUMENT in "$@"; do
        RESULT+=" --tests ${ARGUMENT}"
    done
    echo $RESULT
}

run_gradle_for_test_submodules() {
    local SUBMODULES=$@
    CMD=$(gradle_base_command)
    for SUBMODULE in $SUBMODULES; do
        CMD+=" $(gradle_submodule_arguments $SUBMODULE)"
    done
    echo $CMD
    if [[ $DRY_RUN == 0 ]]; then
        $CMD
    fi
}

run_specific_tests() {
    local SUBMODULE=$1
    shift
    CMD=$(gradle_base_command)
    CMD+=" $(gradle_submodule_arguments $SUBMODULE)"
    for TEST_NAME in "$@"; do
        CMD+=" $(gradle_test_arguments $TEST_NAME)"
    done
    echo $CMD
    if [[ $DRY_RUN == 0 ]]; then
        $CMD
    fi
}

usage() {
    cat <<EOF
kip500-test.sh: runs kip-500 tests.

-a:         run all tests, including core tests.
-d:         dry-run: don't run anything, just echo.
-h:         This help message.
EOF
    exit 0
}

while getopts  "adh" flag; do
    case $flag in
        a) ALL=1;;
        d) DRY_RUN=1;;
        h) usage;;
        *) die "Invalid flag. -h for help.";;
    esac
done

set -e

run_gradle_for_test_submodules \
    server-common \
    shell \
    metadata \
    raft
if [[ $ALL == 1 ]]; then
    run_specific_tests core \
        AlterIsrManagerTest \
        BrokerLifecycleManagerTest \
        BrokerMetadataCheckpointTest \
        BrokerMetadataListenerTest \
        BrokerMetadataSnapshotterTest \
        ClientQuotasRequestTest \
        ClusterToolTest \
        ControllerApisTest \
        DynamicConfigChangeTest \
        InterBrokerSendThreadTest \
        KafkaMetadataLogTest \
        KafkaRaftServerTest \
        KafkaServerTest \
        Kip500ControllerTest \
        LocalConfigRepositoryTest \
        MetadataBrokersTest \
        MetadataCacheTest \
        MetadataPartitionsTest \
        MetadataRequestWithForwardingTest \
        ProducerIdsIntegrationTest \
        RaftClusterSnapshotTest \
        RaftClusterTest \
        StorageToolTest
fi
