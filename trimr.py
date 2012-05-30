#!/usr/bin/python

#
# Trim files from a special 'svn rm' file from a patch.
#

import getopt
import os
import re
import stat
import string
import subprocess
import sys

svn_rm_re = re.compile("svn rm ([^ ]*)")
git_diff_re= re.compile("diff --git ([^ ]*) ([^ ]*)")

## Parse options
def print_usage():
    print os.path.basename(
sys.argv[0]) + ": a program to remove files from a patch.\n\
The files to be removed must be specified in a special 'svn rm' file.\n\
\n\
Usage: " + os.path.basename(sys.argv[0]) + " [options]\n\
\n\
Options: -h: this help message\n\
         -O: automatically determine output patch name\n\
         (rather than sending all output to stdout)\n\
         -p <file-name>: specify patch file (required)\n\
         -r <rm-file>: specify rm file (required)\n\
         -v: turn on verbose mode (to stderr)\n\
"

try:
    optlist, dirs = getopt.getopt(sys.argv[1:], ':hOp:r:v')
except getopt.GetoptError:
    print_usage()
    sys.exit(1)

patch_fname = None
rm_fname = None
verbose = False
auto_set_output_fname = False
outf = sys.stdout
for opt in optlist:
    if opt[0] == '-h':
        print_usage()
        sys.exit(0)
    if opt[0] == '-O':
        auto_set_output_fname = True
    if opt[0] == '-p':
        patch_fname = opt[1]
    if opt[0] == '-r':
        rm_fname = opt[1]
    if opt[0] == '-v':
        verbose = True
if (patch_fname == None):
    print >>sys.stderr, "You must specify a patch name."
    print_usage()
    sys.exit(1)
if (rm_fname == None):
    print >>sys.stderr, "You must specify an 'svn rm' filename."
    print_usage()
    sys.exit(1)
if (auto_set_output_fname):
    auto_set_output_re = re.compile("^(.*).patch$")
    m = auto_set_output_re.match(patch_fname)
    if (not m):
        print >>sys.stderr, "Failed to automatically determine output \
name.  Aborting."
        sys.exit(1)
    output_fname = m.group(1) + ".trimmed.patch"
    if (os.path.exists(output_fname)):
        print >>sys.stderr, "File '" + output_fname + "' already exists!  \
Aborting"
        sys.exit(1)
    outf = open(output_fname, "w")

rms = {}
f = open(rm_fname, "r")
try:
    lineno = 0
    for line in f:
        lineno = lineno + 1
        m = svn_rm_re.match(line)
        if (not m):
            raise RuntimeError("failed to parse line " + lineno + " of " +
                rm_fname)
        rms[str(m.group(1)).rstrip()] = 1
finally:
    f.close()
if (verbose):
    print >>sys.stderr, "removing " + str(len(rms.keys())) + " files from the patch..."

printing = True
f = open(patch_fname, "r")
try:
    for line in f:
        m = git_diff_re.match(line)
        if (not m):
            if (printing):
                print >>outf, line,
        else:
            fname = str(m.group(1))
            #print >>sys.stderr, "fname = '" + fname + "'"
            if (rms.has_key(fname)):
                if (verbose):
                    print >>sys.stderr, "skipping " + fname
                del rms[fname]
                printing = False
            else:
                printing = True
                print >>outf, line,
finally:
    f.close()

if (len(rms.keys()) != 0):
    print >>sys.stderr, "ERROR!  Failed to use all svn rm directives!  Unused:"
    for k in rms.keys():
        print >>sys.stderr, str(k)
    raise RuntimeError("failed to use all svn directives")

sys.exit(0)
