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
	"sort"
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
	commit := Commit {parts[0], strings.TrimSpace(parts[1]), lineno}
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

func (rl *RefLog) LoadFile(name string, il *IgnoreList) error {
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
			_, ignored := il.ignores[*key]
			if (!ignored) {
				rl.commits[*key] = commit
			}
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
			ret += *byLine[i].Match(rl.regex) + " "
		}
		ret += byLine[i].String() + "\n"
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

var branchName *string = flag.String("b", "", "the branch to look for " +
	"commits in")
var regexStr *string = flag.String("r", "(HDFS-[0123456789]*)[^0123456789]",
	"the regular expression to use to determine which commits to examine")
var ignoreFile *string = flag.String("i", "",
	"a file containing a newline-separated list of JIRAs to ignore.  If you " +
	"are using a regex with a backrefernece, each line should contain the " +
	"contents")

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
	il := newIgnoreList()
	if (*ignoreFile != "") {
		err = il.ReadIgnoreFile(*ignoreFile, regex)
		if (err != nil) {
			fmt.Printf("error reading ignore file: %s\n", err)
			os.Exit(1)
		}
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
	err = refLogs[0].LoadFile(fileNames[0], il)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	err = refLogs[1].LoadFile(fileNames[1], il)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	missing := refLogs[0].GetMissing(refLogs[1])
	fmt.Print(missing.String())
}
