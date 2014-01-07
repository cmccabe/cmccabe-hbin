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

listdir = os.path.join(os.environ["HOME"], "list")
jira = sys.argv[1]
branch = sys.argv[2]
branch_suffix = None
if (branch == "trunk"):
    branch_suffix = ""
elif (branch == "branch-1"):
    branch_suffix = "-b1"
elif (branch == "branch-2"):
    branch_suffix = "-b2"
elif (branch == "branch-2.1-beta"):
    branch_suffix = "-b2.1"
elif (branch == "HDFS-4949"):
    branch_suffix = "-caching"
else:
    raise RuntimeError("can't understand branch %s" % branch)
overwrite  = False
if (len(sys.argv) >= 4):
    if (sys.argv[3] == "-f"):
        overwrite = True
    else:
        raise RuntimeError("can't understand option %s" % sys.argv[3])
gpat = listdir + "/" + jira + "_*/"
print "gpat = " + gpat
paths = glob.glob(gpat)
if (len(paths) == 0):
    raise RuntimeError("No directory for " + jira)
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
commit = subprocess.check_output([ "git", "merge-base", "HEAD", branch]).rstrip()
cmd = [ "git", "diff", "--binary", "--no-prefix", commit, "HEAD" ]
outfile = "%s/%s%s.%03d.patch" % (dir_path, jira, branch_suffix, next_patch_num)
print " ".join(cmd) + " > " + outfile
patch = subprocess.check_output(cmd)
f = open(outfile, "w")
try:
    f.write(patch)
finally:
    f.close()
os.system("less '" + outfile + "'")
