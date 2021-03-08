package model

type Table struct {
	Name    string `db:"TABLE_NAME"`
	Comment string `db:"TABLE_COMMENT"`
	Columns []*Column
}
