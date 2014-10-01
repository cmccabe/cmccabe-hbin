#!/bin/bash

mvn test -Dtest=\
TestEnhancedByteBufferAccess,\
TestClientBlockVerification,\
TestDataTransferKeepalive,\
TestParallelShortCircuitReadUnCached,\
TestPipelines,\
TestShortCircuitCache,\
TestBlockTokenWithDFS,\
TestDatanodeJsp,\
TestFsck,\
TestNameNodeHttpServer,\
TestBlockReaderFactory,\
TestHASafeMode
