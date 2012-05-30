#!/bin/bash -x

mvn test -Dtest=TestBlockReport,\
TestDatanodeRegister,\
TestDatanodeVolumeFailure,\
TestBlockPoolManager,\
TestGetBlocks,\
TestHDFSTrash,\
TestHFlush,\
TestInjectionForSimulatedStorage,\
TestLocalDFS,\
TestMultiThreadedHFlush,\
TestPersistBlocks,\
TestPipelines,\
TestPread,\
TestRenameWhileOpen,\
TestShortCircuitLocalRead,\
TestSmallBlock,\
TestWriteRead,\
TestQuota
