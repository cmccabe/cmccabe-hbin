#!/bin/bash -xe

svn revert -R .
svn status | awk '{print $2}' | xargs -l rm
