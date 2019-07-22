package main

import (
	"fmt"
	"os"
	"time"
)


func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, `
%v: converts a time as formatted by ZK into a UNIX time in milliseconds.
`, os.Args[0])
		os.Exit(1)
	}
	timeStr := os.Args[1]
	layout := "1/2/06 3:04:05 PM MST"
	t, err := time.Parse(layout , timeStr); if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing '%s': %s", timeStr, err.Error())
		os.Exit(1)
	}
	ms := t.UTC().UnixNano() / 1000000
	fmt.Printf("%d\n", ms)
}
