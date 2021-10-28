package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)


func main() {
	activeMap := make(map[string]bool)
	scanner := bufio.NewScanner(os.Stdin)
	for scanner.Scan() {
		s := scanner.Text()
		rightBracketIndex := strings.Index(s, "]")
		if rightBracketIndex > 0 {
			handleLine(s[rightBracketIndex+2:], activeMap)
		}
	}
	printMap(activeMap)
}

func handleLine(s string, activeMap map[string]bool) {
	startedIndex := strings.Index(s, "STARTED")
	if startedIndex > 0 {
		activeMap[s[:startedIndex]] = true
		return
	}
	passedIndex := strings.Index(s, "PASSED")
	if passedIndex > 0 {
		delete(activeMap, s[:passedIndex])
		return
	}
	failedIndex := strings.Index(s, "FAILED")
	if failedIndex > 0 {
		delete(activeMap, s[:failedIndex])
		return
	}
	skippedIndex := strings.Index(s, "SKIPPED")
	if skippedIndex > 0 {
		delete(activeMap, s[:skippedIndex])
		return
	}
}

func printMap(activeMap map[string]bool) {
	for t := range(activeMap) {
		fmt.Printf("%s\n", t)
	}
}
