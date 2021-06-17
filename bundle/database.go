package bundle

import (
	"fmt"
	. "github.com/billcoding/golang-code-generator/config"
	. "github.com/billcoding/golang-code-generator/model"
	"strings"
)

func Tables(database string, c *Configuration) []*Table {
	whereSql := ""
	if c.IncludeTables != nil && len(c.IncludeTables) > 0 {
		whereSql = fmt.Sprintf("AND t.`TABLE_NAME` IN('%s')", strings.Join(c.IncludeTables, "','"))
	} else if c.ExcludeTables != nil && len(c.ExcludeTables) > 0 {
		whereSql = fmt.Sprintf("AND t.`TABLE_NAME` NOT IN('%s')", strings.Join(c.ExcludeTables, "','"))
	}
	tableList := SelectTableListSelectMapper.Prepare(map[string]interface{}{
		"DBName": database,
		"Where":  whereSql,
	}).Exec().List(new(Table))
	ts := make([]*Table, len(tableList))
	for i, t := range tableList {
		tt := t.(*Table)
		tt.Columns = make([]*Column, 0)
		ts[i] = tt
	}
	return ts
}

func Columns(database string) []*Column {
	columnList := SelectTableColumnListSelectMapper.Prepare(database).Exec().List(new(Column))
	cs := make([]*Column, len(columnList))
	for i, c := range columnList {
		cs[i] = c.(*Column)
	}
	return cs
}

func TransformTables(tables []*Table) map[string]*Table {
	tableMap := make(map[string]*Table, len(tables))
	for _, t := range tables {
		tableMap[t.Name] = t
	}
	return tableMap
}

func TransformColumns(columns []*Column) map[string]*[]*Column {
	columnMap := make(map[string]*[]*Column, 0)
	for _, c := range columns {
		cs, have := columnMap[c.Table]
		if have {
			*cs = append(*cs, c)
		} else {
			csp := make([]*Column, 1)
			csp[0] = c
			columnMap[c.Table] = &csp
		}
	}
	return columnMap
}

func SetTableColumns(tableMap map[string]*Table, columnMap map[string]*[]*Column) {
	for k, v := range tableMap {
		v.Columns = append(v.Columns, *columnMap[k]...)
	}
}
