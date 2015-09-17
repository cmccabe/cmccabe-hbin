package main

import (
	"strings"
)

type ColumnFormatter struct {
	maxColLen []int
}

func NewColumnFormatter() *ColumnFormatter {
	return &ColumnFormatter {
		maxColLen: make([]int, 0),
	}
}

func (cfr *ColumnFormatter) UpdateMaxColLen(cols []string) {
	for ;len(cfr.maxColLen) < len(cols); {
		cfr.maxColLen = append(cfr.maxColLen, 0)
	}
	for c := range cols {
		if len(cols[c]) + 1 > cfr.maxColLen[c] {
			cfr.maxColLen[c] = len(cols[c]) + 1
		}
	}
}

func (cfr *ColumnFormatter) Format(cols []string) string {
	var str string
	for c := range cols {
		colStr := cols[c]
		numSpaces := 1
		if c < len(cfr.maxColLen) {
			numSpaces = cfr.maxColLen[c] - len(colStr)
		}
		str += (colStr + strings.Repeat(" ", numSpaces))
	}
	return str
}
