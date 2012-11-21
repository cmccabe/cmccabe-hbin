#!/bin/bash -xe

find ~/.m2 -name cmake -type d -exec rm -rf {} \; 
git clean -fqdx
