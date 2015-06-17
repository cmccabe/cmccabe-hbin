#!/usr/bin/python

#
# Hadoop JIRAs generally require a patch file to be attached.
# This script creates such a patch file from a git repo.
#

import glob
import os
import re
import subprocess
import sys

from subprocess import PIPE,Popen

def run_check_output(what):
    proc = Popen(what, stdout=PIPE)
    return (proc.communicate()[0].strip())

listdir = os.path.join(os.environ["HOME"], "list")
jira = sys.argv[1]
branch = sys.argv[2]
branch_suffix = None
if (branch == "trunk"):
    branch_suffix = ""
elif (branch == "master"):
    branch_suffix = ""
elif (branch == "branch-1"):
    branch_suffix = "-b1"
elif (branch == "branch-2"):
    branch_suffix = "-b2"
elif (branch == "branch-2.1-beta"):
    branch_suffix = "-b2.1"
elif (branch == "HDFS-4949"):
    branch_suffix = "-caching"
elif (branch == "HADOOP-10388"):
    branch_suffix = "-pnative"
elif (branch == "HDFS-6994"):
    branch_suffix = "-pnative"
elif (branch == "fs-encryption"):
    branch_suffix = "-fs-enc"
else:
    raise RuntimeError("can't understand branch %s" % branch)
overwrite  = False
mkdirs = False
if (len(sys.argv) >= 4):
    remaining = sys.argv[3:]
    while len(remaining) > 0:
        if remaining[0] == "-f":
            overwrite = True
        elif remaining[0] == "-p":
            mkdirs = True
        else:
            raise RuntimeError("can't understand option %s" % remaining[0])
        remaining = remaining[1:]
gpat = listdir + "/" + jira + "_*/"
print "gpat = " + gpat
paths = glob.glob(gpat)
if (len(paths) == 0):
    if not mkdirs:
        raise RuntimeError("No directory for " + jira)
    paths.append(listdir + "/" + jira + "_jira");
    os.makedirs(paths[0]);
for p in paths[1:]:
    if os.path.isdir(p):
        raise RuntimeError("more than one directory for " + jira)
dir_path = paths[0]
patch_name_re = re.compile(jira + branch_suffix + \
"\.(?P<patch_num>[0123456789][0123456789][0123456789])\.patch")
highest_patch_num = 0
for p in os.listdir(dir_path):
    match = patch_name_re.match(p)
    if (not match):
        continue
    patch_num = int(match.group('patch_num'))
    if (patch_num > highest_patch_num):
        highest_patch_num = patch_num

if (overwrite):
    if (highest_patch_num == 0):
        raise RuntimeError("there is no existing patch to overwrite")
    else:
        next_patch_num = highest_patch_num
else:
    next_patch_num = highest_patch_num + 1
commit = run_check_output([ "git", "merge-base", "HEAD", branch])
cmd = [ "git", "diff", "--binary", commit, "HEAD" ]
outfile = "%s/%s%s.%03d.patch" % (dir_path, jira, branch_suffix, next_patch_num)
print " ".join(cmd) + " > " + outfile
patch = run_check_output(cmd)
f = open(outfile, "w")
try:
    f.write(patch)
finally:
    f.close()
os.system("less '" + outfile + "'")
