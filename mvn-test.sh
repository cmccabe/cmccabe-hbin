#!/bin/bash

mvn test -Pnative -Drequire.test.libhadoop -Dtest=$1
