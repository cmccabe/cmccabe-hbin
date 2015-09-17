/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package main

import (
	"fmt"
	"flag"
	"os"
	"regexp"
	"sort"
	"strings"
)

var branchNames *string = flag.String("b", "", "a comma-separated list of the " +
	"branches to look for commits in.  The 'farthest out' branches should " +
	"come first.")
var regexStr *string = flag.String("r", "(HDFS-[0123456789]*)[^0123456789]",
	"the regular expression to use to determine which commits to examine")

const ANSI_FG_BLACK = "\x1b[30m"
const ANSI_FG_RED = "\x1b[31m"

type Branch struct {
	name string
	refLog *RefLog
}

func LoadBranch(name string, regex *regexp.Regexp) (*Branch, error) {
	brn := &Branch {
		name: name,
	}
	tempFileName := fmt.Sprintf("/tmp/jirafun.%d.%s", os.Getpid(), name)
	defer os.Remove(tempFileName)
	err := gitCommand(tempFileName, "git", "rev-list",
			"--pretty=oneline", brn.name)
	if err != nil {
		return nil, err
	}
	brn.refLog = NewRefLog(regex)
	err = brn.refLog.LoadFile(tempFileName)
	if err != nil {
		return nil, err
	}
	return brn, nil
}

type Change struct {
	// Name, such as HDFS-123
	name string

	// The branches which this change appears on
	branches BitSet
}

func (chg *Change) GetColumns(brn []*Branch) []string {
	lastPresence := 0
	for b := range(brn) {
		if chg.branches.IsSet(b) {
			lastPresence = b
		}
	}
	cols := make([]string, 2 + len(brn))
	cols[0] = "OK"
	cols[1] = chg.name
	for b := range(brn) {
		str := ""
		if b > lastPresence {
			str += "_"
		} else {
			if !chg.branches.IsSet(b) {
				cols[0] = "ERROR "
				//str += ANSI_FG_RED + "[" + brn[b].name + "]" + ANSI_FG_BLACK
				str += "MISSING"
			} else {
				str += brn[b].name
			}
		}
		cols[2 + b] = str
	}
	return cols
}

type ChangeList []*Change

func (clist ChangeList) Len() int {
	return len(clist)
}

func (clist ChangeList) Swap(i, j int) {
	clist[i], clist[j] = clist[j], clist[i]
}

func (clist ChangeList) Less(i, j int) bool {
	return clist[i].name < clist[j].name
}

func IntMax(a int, b int) int {
	if a < b {
		return b
	} else {
		return a
	}
}

func main() {
	flag.Parse()
	regex, err := regexp.Compile(*regexStr)
	if (err != nil) {
		fmt.Printf("Error compiling regular expression \"%s\":\n" +
			"    %s\n", *regexStr, err)
		os.Exit(1)
	}
	if (regex.NumSubexp() > 1) {
		fmt.Printf("Can't handle more than one subexpression in the regular " +
			" expression \"%s\"\n", *regexStr, err)
		os.Exit(1)
	}
	branchNameArr := strings.Split(*branchNames, ",")
	if (len(branchNameArr) < 1) {
		fmt.Printf("You must specify the branches to compare using -b.\n")
		os.Exit(1)
	}
	branches := make([]*Branch, len(branchNameArr))
	for b := range(branchNameArr) {
		branches[b], err = LoadBranch(branchNameArr[b], regex)
		if err != nil {
			fmt.Printf("Error loading branch %s: %s\n",
				branchNameArr[b], err.Error())
			os.Exit(1)
		}
	}

	// Identify which changes are in which branches.
	changes := make(map[string]*Change)
	for b := range(branches) {
		for k, _ := range branches[b].refLog.commits {
			var change *Change
			change = changes[k]
			if change == nil {
				change = &Change{name: k}
				changes[k] = change
			}
			change.branches.Set(b)
		}
	}

	// Sort all changes.
	changeList := make(ChangeList, len(changes))
	i := 0
	for _, v := range changes {
		changeList[i] = v
		i++
	}
	sort.Sort(changeList)

	// Print all changes
	cfr := NewColumnFormatter()
	for c := range changeList {
		cols := changeList[c].GetColumns(branches)
		cfr.UpdateMaxColLen(cols)
	}
	for c := range changeList {
		cols := changeList[c].GetColumns(branches)
		text := cfr.Format(cols)
		if cols[0] == "ERROR" {
			text = ANSI_FG_RED + text + ANSI_FG_BLACK
		}
		fmt.Println(text)
	}
}
