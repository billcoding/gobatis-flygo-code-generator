package main

import (
	"flag"
	"fmt"
	"runtime"
)

func printUsage() {
	fmt.Printf(`Usage of gobatis-flygo-code-generator:

gobatis-flygo-code-generator -mod MODULE -dsn DSN -db DATABASE -OPTIONS

Examples:

gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database"
gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -o "/to/path" 
gobatis-flygo-code-generator -mod "awesomeProject" -dsn "root:123@tcp(127.0.0.1:3306)/test" -db "Database" -au "bigboss" -o "/to/path" 

Supports options:
`)
	flag.PrintDefaults()
}

func printVersion() {
	fmt.Printf(`
github.com/billcoding/gobatis-flygo-code-generator
%s
`, runtime.Version())
}
