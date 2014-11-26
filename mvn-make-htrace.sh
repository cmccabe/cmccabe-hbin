#!/usr/bin/env bash

time mvn package -DskipTests -Dmaven.javadoc.skip=true "$@"
