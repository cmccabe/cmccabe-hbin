#!/bin/bash -x

mvn test -Dtest=TestCheckpoint,\
TestEditLog,\
TestNameNodeRecovery,\
TestEditLogLoading,\
TestNameNodeMXBean,\
TestSaveNamespace,\
TestSecurityTokenEditLog,\
TestStorageDirectoryFailure,\
TestStorageRestore,\
TestFileJournalManager,\
TestEditLogsDuringFailover,\
TestEditLogTailer
