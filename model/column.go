package model

type Column struct {
	Table         string `db:"TABLE_NAME"`
	Name          string `db:"COLUMN_NAME"`
	Type          string `db:"COLUMN_TYPE"`
	ColumnKey     string `db:"COLUMN_KEY"`
	Comment       string `db:"COLUMN_COMMENT"`
	Default       string `db:"COLUMN_DEFAULT"`
	AutoIncrement int    `db:"AUTO_INCREMENT" `
}
