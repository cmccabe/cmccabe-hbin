package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
	"time"
)

// this is for parsing zookeeper logs (once they're dumped to text)
// note: I haven't checked this for bugs

type Tracker struct {
	curTime int64
	curCount int
}

func (t *Tracker) Update(nextTime int64) {
	if t.curTime <= 0 {
		t.curTime = nextTime
		t.curCount = 1
		return
	}
	if nextTime == t.curTime {
		t.curCount++
	} else {
		fmt.Printf("%d, %d\n", t.curTime, t.curCount)
		t.curTime = nextTime
		t.curCount = 1
	}
}

func main() {
	if len(os.Args) != 2 {
		fmt.Fprintf(os.Stderr, `%v: converts a zookeeper log into a timeseries.
The timeseries will contain entries of the form: [timestamp-in-seconds], [entries-in-this-second]
`, os.Args[0])
		os.Exit(1)
	}
    file, err := os.Open(os.Args[1]); if err != nil {
		fmt.Fprintf(os.Stderr, "Failed to open %s: %s\n", os.Args[1], err.Error())
		os.Exit(1)
    }
    defer file.Close()
    scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)
	lineNo := 0
	var tracker Tracker
    for scanner.Scan() {
		lineNo++
		line := strings.TrimSpace(scanner.Text())
		if len(line) <= 0 {
			continue
		}
		index := strings.Index(line, " session")
		if index < 0 {
			fmt.Fprintf(os.Stderr, "Error on line %d: failed to find 'session'\n", lineNo)
			os.Exit(1)
		}
		timeString := line[0:index]
		layout := "1/2/06 3:04:05 PM MST"
		parsedTime, err := time.Parse(layout , timeString); if err != nil {
			fmt.Fprintf(os.Stderr, "Error on line %d: failed to parse '%s': %s\n", lineNo, line, err.Error())
			os.Exit(1)
		}
		tracker.Update(parsedTime.UTC().Unix())
    }
	tracker.Update(-1)
}
