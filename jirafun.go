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
	associatedSvnText string
	status string
}

func (c *Commit) String() string {
	return fmt.Sprintf("%s%s %s%s %s%s %s%s %s",
		c.status, *fieldSeparator, *branchName, *fieldSeparator, c.hash,
		*fieldSeparator, c.text, *fieldSeparator, c.associatedSvnText);
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
	commit := Commit { parts[0], strings.TrimSpace(parts[1]), lineno, "", "???" }
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

func isNumeric(text string) bool {
	for _, cp := range(text) {
		if (cp != '0') && (cp != '1') && (cp != '2') &&
			(cp != '3') && (cp != '4') && (cp != '5') &&
			(cp != '6') && (cp != '7') && (cp != '8') &&
			(cp != '9') {
			return false;
		}
	}
	return true
}

func (c *Commit) PopulateStatus() {
	fileName := fmt.Sprintf("/tmp/jirafun.status.%d", os.Getpid());
	err := gitCommand(fileName, false, "git", "checkout", *mergeBranchName)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	// fmt.Println("processing %v", c)
	err = gitCommand(fileName, false, "git", "reset", "--hard")
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	// fmt.Println(" cherry picking %v", c.hash)
	err = gitCommand(fileName, false, "git", "cherry-pick", strings.TrimSpace(c.hash))
	if err == nil {
		c.status = "CLEAN"
		return
	}
	cmd := exec.Command("git", "checkout", "HEAD", "--",
		"hadoop-hdfs-project/hadoop-hdfs/CHANGES.txt",
		"hadoop-common-project/hadoop-common/CHANGES.txt")
	cmd.Stderr = os.Stderr
	cmd.Stdout = os.Stdout
	if err2 := cmd.Run(); err2 != nil {
		fmt.Print(err2)
		os.Exit(1)
	}

	// use git commit to determine whether the conflict has been resolved.
	err = gitCommand(fileName, false, "git", "commit", "-m", "test")
	resetTo := "HEAD"
	if err != nil {
		c.status = "MERGE ERROR"
	} else {
		c.status = "CLEAN"
		resetTo += "~"
	}
	err = gitCommand(fileName, false, "git", "reset", "--hard", resetTo)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
}

func (c *Commit) PopulateSvnText(jiraId string) {
	words := strings.Fields(c.text)
	ret := ""
	prefix := ""
	for idx := range(words) {
		word := words[idx]
		if (len(word) > 1) && (word[0] == 'r') && isNumeric(word[1:]) {
			ret = ret + prefix + revisionToSvnText(word, jiraId)
			prefix = ", "
		} else if (len(word) > 6) && isNumeric(word) {
			ret = ret + prefix + revisionToSvnText("r" + word, jiraId)
			prefix = ", "
		}
	}
	//fmt.Fprintf(os.Stderr, "%s\n", "c.associatedSvnText = \"" + ret + "\"")
	if ret == "" {
		ret = "(none)"
	}
	c.associatedSvnText = ret
}

func revisionToSvnText(rev string, jiraId string) string {
	if (*associatedSvnRepo == "") {
		return "(no svn repo associated)"
	}
	cmd := exec.Command("svn")
	cmd.Args = []string { "svn", "log", "-r", rev }
	cmd.Stderr = os.Stderr
	cmd.Dir = *associatedSvnRepo
	pipe, err := cmd.StdoutPipe(); if err != nil {
		panic(err.Error())
	}
	scanner := bufio.NewScanner(pipe)
	cmd.Start()
	defer cmd.Wait()
	for scanner.Scan() {
		text := scanner.Text()
		if (strings.Contains(text, jiraId)) {
			return strings.TrimSpace(text)
		}
	}
	fmt.Fprintf(os.Stderr, "failed to find information about %s " +
		"in svn rev %s\n", jiraId, rev)
	return "(no info found for " + rev + ")"
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
			_, ignored := il.ignores[strings.TrimSpace(*key)]
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

func (rl *RefLog) PopulateSvnText() {
	for jiraId, c := range rl.commits {
		c.PopulateSvnText(jiraId)
	}
}

func (rl *RefLog) PopulateStatus() {
	for _, c := range rl.commits {
		c.PopulateStatus()
	}
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
			ret += *byLine[i].Match(rl.regex) + *fieldSeparator + " "
		} else {
			ret += "HDFS-????" + *fieldSeparator + " "
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
			if (regex.MatchString(line)) {
				il.ignores[strings.TrimSpace(line)] = true
				continue
			}
			return err
		} else if (commit == nil) {
			continue
		}
		key := commit.Match(regex)
		if (key != nil) {
			il.ignores[strings.TrimSpace(*key)] = true
		}
	}
	fmt.Fprintf(os.Stderr, "Ignoring %d jiras\n", len(il.ignores));
	return nil
}

func gitCommand(outFile string, printErr bool, args ...string) error {
	f, err := os.Create(outFile)
	if err != nil {
		return err;
	}
	defer f.Close()
	cmd := exec.Command(args[0])
	cmd.Args = args
	if (printErr) {
		cmd.Stderr = os.Stderr
	} else {
		cmd.Stderr = nil
	}
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
var associatedSvnRepo *string = flag.String("s", "",
	"optional local directory with an associated subversion repository.  " +
	"This will be used to make 'merging change rXYZ messages' more helpful.")
var fieldSeparator *string = flag.String("f", "❆", "field separator to use.")
var mergeBranchName *string = flag.String("m", "", "the branch to merge")

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
	err = gitCommand(fileNames[1], true, "git", "rev-list",
		"--pretty=oneline", *branchName)
	if err != nil {
		fmt.Print(err)
		os.Exit(1)
	}
	err = gitCommand(fileNames[0], true, "git", "rev-list",
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
	missing.PopulateSvnText()
	if (*mergeBranchName != "") {
		missing.PopulateStatus()
	}
	fmt.Printf("JIRA%s status%s branch%s git hash%s commit text%s" +
		"svn auxillary text\n",
		*fieldSeparator, *fieldSeparator, *fieldSeparator,
		*fieldSeparator, *fieldSeparator)

	fmt.Print(missing.String())
}
