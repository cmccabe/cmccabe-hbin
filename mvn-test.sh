#!/usr/bin/env bash

SCRIPT_DIR="$(dirname "$0")"
source "$SCRIPT_DIR/mvn-common-env.sh"

mvn test -Pnative -Drequire.test.libhadoop $@
