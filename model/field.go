package model

type Field struct {
	Name             string
	Type             string
	OpName           string
	OpVar            string
	Comment          bool
	ColumnAnnotation bool
	JSONTag          bool
	JSONTagName      string
	Column           *Column
	HaveDefault      bool
	Default          string
}
