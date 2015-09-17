/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
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
