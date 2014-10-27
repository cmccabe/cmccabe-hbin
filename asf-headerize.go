package main

import (
	"bufio"
	"bytes"
	"fmt"
	"io/ioutil"
	"os"
	"strings"
)

var apacheHeader = []string {
	"/**",
	" * Licensed to the Apache Software Foundation (ASF) under one",
	" * or more contributor license agreements.  See the NOTICE file",
	" * distributed with this work for additional information",
	" * regarding copyright ownership.  The ASF licenses this file",
	" * to you under the Apache License, Version 2.0 (the",
	" * \"License\"); you may not use this file except in compliance",
	" * with the License.  You may obtain a copy of the License at",
	" *",
	" *     http://www.apache.org/licenses/LICENSE-2.0",
	" *",
	" * Unless required by applicable law or agreed to in writing, software",
	" * distributed under the License is distributed on an \"AS IS\" BASIS,",
	" * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.",
	" * See the License for the specific language governing permissions and",
	" * limitations under the License.",
	" */",
	"",
}

func stripBadHeader(fileName string) error {
	arr, err := ioutil.ReadFile(fileName); if err != nil {
		return err
	}

	// Look for the start of the Apache header.
	reader := bytes.NewReader(arr)
	scanner := bufio.NewScanner(reader)
	line := ""
	for scanner.Scan() {
		line = scanner.Text()
		if strings.HasPrefix(line, "#") {
			break
		}
	}

	// Read the remainder, which we want to save.
	var lines []string
	for i := range(apacheHeader) {
		lines = append(lines, apacheHeader[i])
	}
	lines = append(lines, line)
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	// Rewrite the file without the header.
	var file *os.File
	file, err = os.OpenFile(fileName, os.O_WRONLY | os.O_TRUNC, 0666); if err != nil {
		return err
	}
	for l := range lines {
		_, err = file.WriteString(lines[l] + "\n"); if err != nil {
			return err
		}
	}
	err = file.Close(); if err != nil {
		return err
	}
	return nil
}

func main() {
	if len(os.Args) == 1 {
		fmt.Fprintf(os.Stderr, `
%v: puts an ASF header on C/C++ code or header files.

We look for the first line with a #, and then discard all previous lines, slap
a header on, and pass the rest through unchanged.
`, os.Args[0])
	}
	for i := 1; i < len(os.Args); i++ {
		err := stripBadHeader(os.Args[i]); if err != nil {
			panic(err)
		}
	}
}
