package main

import (
	"flag"
	"fmt"
	"runtime"
)

func printUsage() {
	fmt.Printf(`Usage of golang-code-generator:

golang-code-generator -mod MODULE -dsn DSN -db DATABASE -OPTIONS

Examples:

golang-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database"
golang-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -o "/to/path" 
golang-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -au "bigboss" -o "/to/path" 

Supports options:
`)
	flag.PrintDefaults()
}

func printVersion() {
	fmt.Printf(`
github.com/billcoding/golang-code-generator
%s
`, runtime.Version())
}
