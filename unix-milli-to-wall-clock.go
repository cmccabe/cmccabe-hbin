package main

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, `
%v: converts a UNIX time in milliseconds to a human-readable string.
`, os.Args[0])
		os.Exit(1)
	}
	timeStr := os.Args[1]
	timeVal, err := strconv.ParseInt(timeStr, 10, 64); if err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing input: %s", err.Error())
		os.Exit(1)
	}
	timeSec := timeVal / 1000
	timeNano := timeVal - (timeSec * 1000)
	timeUnix := time.Unix(timeSec, timeNano).UTC()
	fmt.Printf("%s\n", timeUnix.Format(time.RFC1123Z))
}
