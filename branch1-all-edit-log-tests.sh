#!/bin/bash -xe

TESTS="TestCheckpoint \
TestEditLog \
TestNameNodeRecovery \
TestEditLogLoading \
TestNameNodeMXBean \
TestSaveNamespace \
TestSecurityTokenEditLog \
TestStorageDirectoryFailure \
TestEditLogToleration \
TestStorageRestore"

for t in $TESTS; do
    ant test -Dtestcase=$t
done
