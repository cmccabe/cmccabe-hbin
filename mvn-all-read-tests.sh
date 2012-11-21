#!/bin/bash -x

mvn test -Dtest=TestShortCircuitLocalRead,\
TestParallelRead,\
TestParallelShortCircuitRead,\
TestParallelShortCircuitReadNoChecksum,\
TestParallelUnixDomainRead,\
TestBlockReaderLocal
