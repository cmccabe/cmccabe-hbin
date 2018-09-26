package main

import (
  "bufio"
  "io"
  "fmt"
  "os"
  "path/filepath"
  "sort"
  "strings"
)

func printUsage() {
	fmt.Printf("java_merge [output_directory] [input_directories...]\n")
	fmt.Printf("\n")
	fmt.Printf("Merges the input source trees into the output source tree.\n")
}

func printCopies(copies map[string]string) {
	keys := make(sort.StringSlice, 0, len(copies))
	for k, _ := range(copies) {
		keys = append(keys, k)
	}
	sort.Sort(keys)
	for i := range(keys) {
		fmt.Printf("%s ->\n\t%s\n", keys[i], copies[keys[i]])
	}
}

func askYesNo() bool {
	reader := bufio.NewReader(os.Stdin)
	for {
		fmt.Printf("[Y/N]? ")
		text, err := reader.ReadString('\n')
		if err != nil {
			fmt.Printf("Unable to read from stdin: %s", err)
			return false
		}
		text = strings.TrimSpace(text)
		if text == "Y" || text == "y" {
			return true
		}
		if text == "N" || text == "n" {
			return false
		}
		fmt.Printf("Please enter Y or N.\n\n")
	}
}

func copyFiles(copies map[string]string) error {
	keys := make(sort.StringSlice, 0, len(copies))
	for k, _ := range(copies) {
		keys = append(keys, k)
	}
	sort.Sort(keys)
	for i := range(keys) {
		err := copyFile(copies[keys[i]], keys[i]); if err != nil {
			return err
		}
	}
	return nil
}

func copyFile(dst string, src string) error {
	// Open the source file.
	srcFile, err := os.Open(src); if err != nil {
		return fmt.Errorf("Unable to open input file %s: %s", src, err.Error())
	}
	defer srcFile.Close()

	// Make sure the destination directory exists.
	dir := filepath.Dir(dst)
	err = os.MkdirAll(dir, 0777); if err != nil {
		return fmt.Errorf("Unable to mkdirAll %s: %s", dir, err.Error())
	}

	// Create and open the destination file.
	dstFile, err := os.OpenFile(dst, os.O_CREATE | os.O_WRONLY | os.O_TRUNC, 0666)
	if err != nil {
		return fmt.Errorf("Unable to open output file %s: %s", src, err.Error())
	}

	// Copy and sync.
	_, err = io.Copy(dstFile, srcFile); if err != nil {
		return fmt.Errorf("Error copinyg input file %s to output file %s: %s",
			src, dst, err.Error())
	}
	err = dstFile.Sync(); if err != nil {
		return fmt.Errorf("Error syncing input file %s to output file %s: %s",
			src, dst, err.Error())
	}
	defer dstFile.Close()
	return nil
}

func scheduleCopies(outputPath string, inputPath string, copies map[string]string) error {
	return filepath.Walk(inputPath, func(curPath string, info os.FileInfo, err error) error {
		if err != nil {
			return fmt.Errorf("Error walking the directory tree: %s", err.Error())
		}
		if strings.HasSuffix(curPath, ".java") {
			curSuffix := curPath[len(inputPath):]
			nextPath := filepath.Join(outputPath, curSuffix)
			copies[curPath] = nextPath
		}
		return nil;
	})
}

func main() {
	if (len(os.Args) < 2) {
		printUsage()
		os.Exit(1)
	}
	copies := make(map[string]string)
	outputPath := os.Args[1]
	inputPaths := os.Args[2:]
	for i := range(inputPaths) {
		err := scheduleCopies(outputPath, inputPaths[i], copies)
		if err != nil {
			panic(fmt.Sprintf("scheduleCopies %s failed: %s",
				inputPaths[i], err.Error()))
		}
	}
	printCopies(copies)
	fmt.Printf("Is this OK? ")
	if (!askYesNo()) {
		os.Exit(0)
	}
	err := copyFiles(copies)
	if err != nil {
		panic(fmt.Sprintf("copyFiles failed: %s", err.Error()))
	}
}
