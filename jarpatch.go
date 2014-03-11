package main

import (
	"errors"
	"flag"
	"fmt"
	"hash/crc32"
	"io/ioutil"
	"os"
	"path"
	"strings"
)

const JAR_SUFFIX = ".jar"

func getFileCrc32(filePath string) (uint32, error) {
	// TODO: don't read the whole file into memory here
	bs, err := ioutil.ReadFile(filePath)
	if err != nil {
		return 0, err
	}
	h := crc32.NewIEEE()
	h.Write(bs)
	return h.Sum32(), nil
}

type Jar struct {
	name string
	jarPath string
}

func (j *Jar) Compare(o *Jar) (bool, error) {
	var statJ, statO os.FileInfo
	var err error
	statJ, err = os.Stat(j.jarPath); if err != nil {
		return false, err
	}
	statO, err = os.Stat(o.jarPath); if err != nil {
		return false, err
	}
	if statJ.Size() != statO.Size() {
		return false, nil
	}
	var crcJ, crcO uint32
	crcJ, err = getFileCrc32(j.jarPath); if err != nil {
		return false, err
	}
	crcO, err = getFileCrc32(o.jarPath); if err != nil {
		return false, err
	}
	return crcJ == crcO, nil
}

var installedPath *string = flag.String("i", "", "the install path")
var updatePath *string = flag.String("u", "", "the update path")
var dryRun *bool = flag.Bool("d", false, "Do a dry-run (don't copy anything)")
var verbose *bool = flag.Bool("v", false, "Be verbose")

func locateJars(curPath string, jars map[string]Jar) error {
	stat, err := os.Stat(curPath); if err != nil {
		return err
	}
	if (stat.IsDir()) {
		var infos []os.FileInfo
		infos, err = ioutil.ReadDir(curPath); if err != nil {
			return err
		}
		for idx := range(infos) {
			locateJars(curPath + "/" + infos[idx].Name(), jars)
		}
	} else {
		if strings.HasSuffix(curPath, JAR_SUFFIX) {
			name := path.Base(curPath)
			if _, ok := jars[name]; ok {
				return errors.New("There were two locations for " + name + 
					" one at " + curPath + ", and another at " +
					jars[name].jarPath)
			}
			jars[name] = Jar { name, curPath }
		}
	}
	return nil
}

func main() {
	flag.Parse()
	var err error

	if *installedPath == "" {
		fmt.Fprintf(os.Stderr, "You must give an installed path.  -h " +
			"for help.\n")
		os.Exit(1)
	}
	if *updatePath == "" {
		fmt.Fprintf(os.Stderr, "You must give an update path.  -h " +
			"for help.\n")
		os.Exit(1)
	}
	installedJars := make(map[string]Jar)
	err = locateJars(*installedPath, installedJars); if err != nil {
		fmt.Fprintf(os.Stderr, "Error locating installed jars in %s: %s\n",
			*installedPath, err.Error())
		os.Exit(1)
	}
	updateJars := make(map[string]Jar)
	err = locateJars(*updatePath, updateJars); if err != nil {
		fmt.Fprintf(os.Stderr, "Error locating update jars in %s: %s\n",
			*updatePath, err.Error())
		os.Exit(1)
	}
	for updateJarName, updateJar := range(updateJars) {
		if installedJar, ok := installedJars[updateJarName]; ok {
			var same bool
			same, err = installedJar.Compare(&updateJar); if err != nil {
				fmt.Fprintf(os.Stderr, "Error comparing jars " +
					"%s and %s: %s\n", installedJar.jarPath,
					updateJar.jarPath, err.Error())
				os.Exit(1)
			}
			if (same) {
				if (*verbose) {
					fmt.Printf("update jar " + updateJar.jarPath +
						" matches installed jar " + installedJar.jarPath + "\n")
				}
			} else {
				fmt.Printf("update jar " + updateJar.jarPath +
					" does not match installed jar " + installedJar.jarPath + "\n")
				// TODO: copy update jar over when dry-run == false
			}
		} else {
			if (*verbose) {
				fmt.Printf("ignoring update jar " + updateJarName +
					" because there is no matching installed jar.\n")
			}
		}
	}
}
