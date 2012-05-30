#!/bin/bash -x

mvn -Dfindbugs.home=/opt/findbugs-1.3.8/ compile findbugs:findbugs
