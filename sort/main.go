package main

import (
	"bufio"
	"fmt"
	"os"

	"golang.org/x/text/collate"
	"golang.org/x/text/language"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	var inputs []string

	for scanner.Scan() {
		inputs = append(inputs, scanner.Text())
	}
	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "reading standard input:", err)
	}

	// I could use https://golang.org/pkg/sort with something like
	// sort.Strings(inputs) but i'd have the same issue as before.
	// Let's use this "undefined" language which is at least UTF-8
	// aware.  Stolen from
	// https://lemire.me/blog/2018/12/17/sorting-strings-properly-is-stupidly-hard
	c := collate.New(language.Und)
	c.SortStrings(inputs)

	for _, s := range inputs {
		fmt.Println(s)
	}
}
