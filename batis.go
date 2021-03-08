package main

import (
	. "github.com/billcoding/gobatis"
	_ "github.com/go-sql-driver/mysql"
)

var (
	SelectTableListSelectMapper       *SelectMapper
	SelectTableColumnListSelectMapper *SelectMapper
)

func initBatis() {
	Default().DSN(*dsn)

	Default().AddRaw(tableXML)

	SelectTableListSelectMapper = NewHelper("table", "SelectTableList").Select()
	SelectTableColumnListSelectMapper = NewHelper("table", "SelectTableColumnList").Select()
}
