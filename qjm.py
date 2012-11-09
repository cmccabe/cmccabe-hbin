#!/usr/bin/python

import getopt
import os
import signal
import string
import sys

def file_to_pid(fname):
    if (not os.path.exists(fname)):
        return -1
    f = open(fname, 'r')
    pid = int(f.readline())
    f.close()
    return pid

def pid_to_file(fname, pid):
    f = open(fname, 'w')
    f.write(str(pid))
    f.close()

def file_to_running(fname):
    if (not os.path.exists(fname)):
        return False
    pid = file_to_pid(fname)
    return os.path.isdir("/proc/" + str(pid))

class Node(object):
    def __init__(self, ident, ty):
        self.ident = ident
        self.ty = ty
    def get_pid_file(self):
        return "/tmp/qjm.pid." + str(self.ty) + "." + str(self.ident)
    def get_conf_dir(self):
        if (self.ty == "journal"):
            return "jn" + str(self.ident)
        elif (self.ty == "name"):
            return "nn" + str(self.ident)
        elif (self.ty == "data"):
            return "dn" + str(self.ident)
    def get_log_file(self):
        if (self.ty == "journal"):
            return "/r/logs/jn" + str(self.ident) + ".log"
        elif (self.ty == "name"):
            return "/r/logs/nn" + str(self.ident) + ".log"
        elif (self.ty == "data"):
            return "/r/logs/dn" + str(self.ident) + ".log"
    def get_hadoop_command(self):
        cmd = [ "/home/cmccabe/cmccabe-hbin/doit",
            "/home/cmccabe/cmccabe-hbin/doit",
            self.get_conf_dir(),
            "-redirect", self.get_log_file(), 
            "/h/bin/hdfs" ]
        if (self.ty == "journal"):
            cmd.append("journalnode")
        elif (self.ty == "name"):
            cmd.append("namenode")
        elif (self.ty == "data"):
            cmd.append("datanode")
        return cmd
    def __str__(self):
        return self.ty + "(" + str(self.ident) + ")"
    def start(self):
        if (file_to_running(self.get_pid_file())):
            print str(self) + " is already running as pid " + \
                str(file_to_pid(self.get_pid_file()))
            return
        cmd = self.get_hadoop_command()
        print string.join(cmd[1:])
        pid = os.spawnv(os.P_NOWAIT, cmd[0], cmd[1:])
        pid_to_file(self.get_pid_file(), pid)
        print str(self) + " started as pid " + str(pid)
    def stop(self):
        if (not file_to_running(self.get_pid_file())):
            print str(self) + " daemon is not running (expected pid: " + \
                str(file_to_pid(self.get_pid_file())) + ")"
            return
        pid = file_to_pid(self.get_pid_file())
        try:
            os.kill(pid, signal.SIGTERM)
        except Exception, e:
            print "error while sending SIGTERM to " + str(pid) + ": " + str(e)

#################################################################################
journalnodes = [ Node(1, "journal"), Node(2, "journal"), Node(3, "journal") ]

namenodes = [ Node(1, "name"), Node(2, "name") ]

datanodes = [ Node(1, "data") ]

allnodes = journalnodes + namenodes + datanodes

#################################################################################
def usage():
    print """
qjm: testing script for qjm-enabled clusters.

usage: qjm [options] [action]

options:
    -d: apply to DataNodes only
    -h: this help message
    -j: apply to JournalNodes only
    -n: apply to NameNodes only

actions:
    start: start all daemons
    stop: stop all daemons
"""

try:
    optlist, next_args = getopt.getopt(sys.argv[1:], ':dhjn')
except getopt.GetoptError:
    usage()
    sys.exit(1)

target = [ "data", "journal", "name" ]
for opt in optlist:
    if opt[0] == '-h':
        usage()
        sys.exit(0)
    if opt[0] == '-d':
        target = [ "data" ]
    if opt[0] == '-j':
        target = [ "journal" ]
    if opt[0] == '-n':
        target = [ "name" ]

if (len(next_args) < 1):
    usage()
    sys.exit(1)
elif (next_args[0] == "start"):
    action = "start"
elif (next_args[0] == "stop"):
    action = "stop"
else:
    action = "help"

if action == "help":
    usage()
    sys.exit(0)
elif action == "start":
    for node in allnodes:
        if (node.ty in target):
            node.start()
elif action == "stop":
    for node in allnodes:
        if (node.ty in target):
            node.stop()
