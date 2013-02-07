#!/bin/bash -xe

outdir=${1-/tmp/hadoop-site}
rm -rf ${outdir}
mvn site
mvn site:stage -DstagingDirectory=${outdir}
