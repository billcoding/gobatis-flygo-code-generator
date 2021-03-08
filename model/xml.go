package model

type XML struct {
	Mapper    *Mapper
	ResultMap *ResultMap
}

type ResultMap struct {
	HaveId bool
	Id     *Field
	Items  []*Field
}
