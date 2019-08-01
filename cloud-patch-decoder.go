package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const DIFF_PREFIX = "diff --git "

const BINDATA_SUFFIX = "/bindata.go"

func shouldIgnore(line string) bool {
	if strings.Contains(line, ".pb.go ") {
		return true
	}
	if strings.HasSuffix(line, BINDATA_SUFFIX) {
		return true
	}
	return false
}

func main() {
	if len(os.Args) <= 1 {
		fmt.Fprintf(os.Stderr, `
%v: decodes cloud patches by removing generated files.
`, os.Args[0])
	}
	file, err := os.Open(os.Args[1]); if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open %s: %s\n", os.Args[1], err.Error())
		os.Exit(1)
	}
	defer file.Close()
	ignore := false
	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if strings.HasPrefix(line, DIFF_PREFIX) {
			ignore = shouldIgnore(line)
		}
		if !ignore {
			fmt.Println(line)
		}
	}
}
