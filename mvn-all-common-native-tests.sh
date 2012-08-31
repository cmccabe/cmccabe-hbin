#!/bin/bash -x

mvn test -Dtest=TestNativeIO,\
TestJNIGroupsMapping,\
TestCrcCorruption
