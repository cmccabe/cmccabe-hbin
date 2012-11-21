package main

import (
	"bufio"
	"errors"
	"fmt"
	"flag"
	"io"
	"os"
	"os/exec"
	"regexp"
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
		parts := strings.SplitAfterN(line, " ", 2)
		if (len(parts) < 2) {
			return errors.New(fmt.Sprintf("failed to find a space " +
				"on line %d", lineno))
		}
		commit := Commit {parts[0], strings.TrimSpace(parts[1]), lineno}
		key := commit.Match(rl.regex)
		if (key != nil) {
			rl.commits[*key] = &commit
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

//func (rl *RefLog) ReadIgnoreFile(name string) {
//}

func (rl *RefLog) String() string {
	byLine := make(map[int] *Commit)
	for _, c := range rl.commits {
		byLine[c.lineno] = c
	}
	ret := ""
	for _, v := range byLine {
		if (rl.regex.NumSubexp() > 0) {
			ret += *v.Match(rl.regex) + " "
		}
		ret += v.String() + "\n"
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
var regexStr *string = flag.String("r", "(HDFS-[0123456789]*)[^0123456789]",
	"the regular expression to use to determine which commits to examine")

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
	if (*branchName == "") {
		fmt.Printf("You must specify a branch to compare against using -b.\n")
		os.Exit(1)
	}
	fileNames := []string {
		fmt.Sprintf("/tmp/jirafun.1.%d", os.Getpid()),
		fmt.Sprintf("/tmp/jirafun.2.%d", os.Getpid()) }
	defer os.Remove(fileNames[0])
	defer os.Remove(fileNames[1])
	err = gitCommand(fileNames[1], "git", "rev-list",
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
	refLogs := []*RefLog { NewRefLog(regex), NewRefLog(regex) }
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
