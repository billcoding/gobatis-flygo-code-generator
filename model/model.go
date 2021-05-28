package model

type Model struct {
	PKG             string
	Name            string
	FileName        string
	Comment         bool
	Table           *Table
	Fields          []*Field
	DefaultFields   []*Field
	NoDefaultFields []*Field
	HaveId          bool
	Ids             []*Field
	ImportTime      bool
	IntId           bool
	IdCount         int
	AutoIncrement   bool
}
