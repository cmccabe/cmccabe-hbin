package main

import (
	"bufio"
	"errors"
	"fmt"
	"flag"
	"io"
	"os"
	"os/exec"
	"strings"
)

type Commit struct {
	hash string
	text string
	lineno int
}

func (c *Commit) String() string {
	return fmt.Sprintf("%s %s", c.hash, c.text);
}

type RefLog struct {
	commits map[string] *Commit
}

func NewRefLog() *RefLog {
	refLog := new(RefLog)
	refLog.commits = make(map[string] *Commit)
	return refLog
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
		parts := strings.SplitAfterN(line, " ", 2)
		if (len(parts) < 2) {
			return errors.New(fmt.Sprintf("failed to find a space " +
				"on line %d", lineno))
		}
		commit := Commit {parts[0], parts[1], lineno}
		rl.commits[commit.text] = &commit
	}
	return nil
}

func (rl *RefLog) GetMissing(alt *RefLog) *RefLog {
	missing := NewRefLog()
	for _, c := range alt.commits {
		_, present := rl.commits[c.text]
		if (!present) {
			missing.commits[c.text] = c
		}
	}
	return missing
}

//func (rl *RefLog) ReadIgnoreFile(name string) {
//}

func (rl *RefLog) String() string {
	byLine := make(map[int] *Commit)
	for _, c := range rl.commits {
		byLine[c.lineno] = c
	}
	ret := ""
	for _, v := range byLine {
		ret += v.String()
	}
	return ret;
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

var branchName *string = flag.String("b", "", "the branch to look for " +
	"commits in")

func main() {
	flag.Parse()
	if (*branchName == "") {
		fmt.Printf("You must specify a branch to compare against using -b.\n")
		os.Exit(1)
	}
	fileNames := []string {
		fmt.Sprintf("/tmp/jirafun.1.%d", os.Getpid()),
		fmt.Sprintf("/tmp/jirafun.2.%d", os.Getpid()) }
	defer os.Remove(fileNames[0])
	defer os.Remove(fileNames[1])
	err := gitCommand(fileNames[1], "git", "rev-list",
		"--pretty=oneline", *branchName)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	err = gitCommand(fileNames[0], "git", "rev-list",
		"--pretty=oneline", "HEAD")
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	refLogs := []*RefLog { NewRefLog(), NewRefLog() }
	err = refLogs[0].LoadFile(fileNames[0])
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	err = refLogs[1].LoadFile(fileNames[1])
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	missing := refLogs[0].GetMissing(refLogs[1])
	fmt.Print(missing.String())
}
