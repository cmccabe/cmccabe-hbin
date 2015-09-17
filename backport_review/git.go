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
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"sort"
	"strings"
)

type Commit struct {
	hash string
	text string
	lineno int
}

func CommitFromLine(line string, lineno int) (*Commit, error) {
	if ((len(line) > 0) && (line[0] == '#')) {
		// this is a comment line; ignore it
		return nil, nil
	}
	parts := strings.SplitAfterN(line, " ", 2)
	if (len(parts) < 2) {
		return nil, errors.New(fmt.Sprintf("failed to find a space " +
			"on line %d", lineno))
	}
	commit := Commit { parts[0], strings.TrimSpace(parts[1]), lineno }
	return &commit, nil
}

func (c *Commit) Match(regex *regexp.Regexp) *string {
	if (regex.NumSubexp() == 1) {
		m := regex.FindStringSubmatch(c.text)
		if m == nil {
			return nil
		}
		return &m[1]
	} else {
		if (!regex.MatchString(c.text)) {
			return nil;
		}
		return &c.text
	}
	return nil
}

type RefLog struct {
	commits map[string] *Commit
	regex *regexp.Regexp
}

func NewRefLog(regex *regexp.Regexp) *RefLog {
	rl := new(RefLog)
	rl.commits = make(map[string] *Commit)
	rl.regex = regex
	return rl
}

func (rl *RefLog) LoadFile(name string) error {
	lineno := 1
	f, err := os.Open(name)
	if err != nil {
		return err;
	}
	defer f.Close()
	for fileBuf := bufio.NewReader(f); ; lineno++ {
		line, err := fileBuf.ReadString('\n')
		if (err != nil) {
			if (err == io.EOF) {
				break
			} else {
				return err
			}
		}
		var commit *Commit
		commit, err = CommitFromLine(line, lineno)
		if (err != nil) {
			return err
		}
		if (commit == nil) {
			continue
		}
		key := commit.Match(rl.regex)
		if (key != nil) {
//			_, ignored := il.ignores[*key]
//			if (!ignored) {
				rl.commits[*key] = commit
//			}
		}
	}
	return nil
}

func (rl *RefLog) GetMissing(alt *RefLog) *RefLog {
	missing := NewRefLog(rl.regex)
	for k, c := range alt.commits {
		_, present := rl.commits[k]
		if (!present) {
			missing.commits[k] = c
		}
	}
	return missing
}

type CommitSlice []*Commit
func (arr CommitSlice) Len() int { return len(arr) }
func (arr CommitSlice) Less(i, j int) bool { return arr[i].lineno < arr[j].lineno }
func (arr CommitSlice) Swap(i, j int) { arr[i], arr[j] = arr[j], arr[i] }

func (rl *RefLog) String() string {
	byLine := make(CommitSlice, len(rl.commits))
	i := 0
	for _, c := range rl.commits {
		byLine[i] = c
		i++
	}
	sort.Sort(byLine)
	ret := ""
	for i = 0; i < len(byLine); i++ {
		if (rl.regex.NumSubexp() > 0) {
			ret += *byLine[i].Match(rl.regex) + "\t"
		} else {
			ret += "HDFS-????" + "\t"
		}
		ret += byLine[i].text + "\n"
	}
	return ret;
}

type IgnoreList struct {
	ignores map[string] bool
}

func newIgnoreList() *IgnoreList {
	il := new(IgnoreList)
	il.ignores = make(map[string] bool)
	return il
}
func (il *IgnoreList) ReadIgnoreFile(fileName string,
		regex *regexp.Regexp) error {
	f, err := os.Open(fileName)
	if (err != nil) {
		return err
	}
	defer f.Close()
	lineno := 1
	for fileBuf := bufio.NewReader(f); ; lineno++ {
		line, err := fileBuf.ReadString('\n')
		if (err != nil) {
			if (err == io.EOF) {
				break
			} else {
				return err
			}
		}
		var commit *Commit
		commit, err = CommitFromLine(line, lineno)
		if (err != nil) {
			return err
		} else if (commit == nil) {
			continue
		}
		key := commit.Match(regex)
		if (key != nil) {
			il.ignores[*key] = true
		}
	}
	return nil
}

func gitCommand(outFile string, args ...string) error {
	f, err := os.Create(outFile)
	if err != nil {
		return err;
	}
	defer f.Close()
	cmd := exec.Command(args[0])
	cmd.Args = args
	cmd.Stderr = os.Stderr
	cmd.Stdout = f
	if err2 := cmd.Run(); err2 != nil {
		return err2
	}
	return nil
}
