package {{.Config.Mapper.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
    . "github.com/billcoding/gobatis"
    p "github.com/billcoding/gobatis/predicate"
    . "{{.Config.Module}}/{{.Mapper.Model.PKG}}"
    c "{{.Config.Module}}/{{.Config.Config.PKG}}"
    "strings"
)

var {{.Mapper.VarName}} = &{{.Mapper.Name}}{
	insertMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "Insert").Update()
	},
	deleteByIDMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByID").Update()
	},
	updateByIDMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "UpdateByID").Update()
	},
	selectByIDMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByID").Select()
	},
	selectByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByModel").Select()
	},
	selectPageByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectPageByModel").Select()
	},
	selectPageMapByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectPageMapByModel").Select()
	},
}

{{if .Config.Model.Comment}}// {{.Mapper.Name}} {{.Mapper.Model.Table.Comment}} Mapper{{end}}
type {{.Mapper.Name}} struct {
	insertMapper               func() *UpdateMapper
    deleteByIDMapper           func() *UpdateMapper
	updateByIDMapper           func() *UpdateMapper
	selectByIDMapper           func() *SelectMapper
	selectByModelMapper        func() *SelectMapper
	selectPageByModelMapper    func() *SelectMapper
	selectPageMapByModelMapper func() *SelectMapper
}
{{if .Mapper.Model.IntId}}{{if lt .Mapper.Model.IdCount 2}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) (bool, int64) {
    return m.InsertWithTX(nil, model)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) (bool, int64) {
    insertMapper := m.insertMapper()
    insertMapper.Args({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(insertMapper)
	} else {
	    err = insertMapper.Exec()
	}
	if err == nil {
		return true, insertMapper.InsertedId()
	}
	return false, 0
}
{{end}}{{else}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) bool {
    return m.InsertWithTX(nil, model)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) bool {
    insertMapper := m.insertMapper()
    insertMapper.Args({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(insertMapper)
	} else {
	    err = insertMapper.Exec()
	}
	return err == nil
}{{end}}

// DeleteByID deletes one record by ID
func (m *{{.Mapper.Name}}) DeleteByID({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}},{{end}}{{$e.Name}} {{$e.Type}}{{end}}) bool {
    return m.DeleteByIDWithTX(nil, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
}

// DeleteByIDWithTX deletes one record by ID with a tx
func (m *{{.Mapper.Name}}) DeleteByIDWithTX(TX *TX, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) bool {
    deleteByIDMapper := m.deleteByIDMapper().Args({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(deleteByIDMapper)
        return true
    }
    return deleteByIDMapper.Exec() == nil
}

// UpdateByID updates one record by ID
func (m *{{.Mapper.Name}}) UpdateByID(model *{{.Mapper.Model.Name}}) bool {
    return m.UpdateByIDWithTX(nil, model)
}

// UpdateByIDWithTX updates one record by ID with a tx
func (m *{{.Mapper.Name}}) UpdateByIDWithTX(TX *TX, model *{{.Mapper.Model.Name}}) bool {
    updateByIDMapper := m.updateByIDMapper().Args({{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}}{{range $i,$e := .Mapper.Model.Ids}}, model.{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(updateByIDMapper)
        return true
    }
    return updateByIDMapper.Exec() == nil
}

// SelectByID selects one record by ID
func (m *{{.Mapper.Name}}) SelectByID({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) *{{.Mapper.Model.Name}} {
	list := m.selectByIDMapper().Args({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}}).Exec().List(new({{.Mapper.Model.Name}}))
	if len(list) > 0 {
		return list[0].(*{{.Mapper.Model.Name}})
	}
	return nil
}

// SelectOneByModel selects one by model
func (m *{{.Mapper.Name}}) SelectOneByModel(model *{{.Mapper.Model.Name}}) *{{.Mapper.Model.Name}} {
	return m.SelectOneByModelAndSort(model, nil)
}

// SelectOneByModelAndSort selects one by model with sort
func (m *{{.Mapper.Name}}) SelectOneByModelAndSort(model *{{.Mapper.Model.Name}}, sorts ...p.Sort) *{{.Mapper.Model.Name}} {
	list := m.SelectByModelAndSort(model, sorts...)
	if len(list) > 0 {
		return list[0]
	}
	return nil
}

// SelectOneByCond selects one by cond
func (m *{{.Mapper.Name}}) SelectOneByCond(conds ...p.Cond) *{{.Mapper.Model.Name}} {
	return m.SelectOneByCondAndSort(conds, nil)
}

// SelectOneByCondAndSort selects one by cond with sort
func (m *{{.Mapper.Name}}) SelectOneByCondAndSort(conds []p.Cond, sorts ...p.Sort) *{{.Mapper.Model.Name}} {
	list := m.SelectByCondAndSort(conds, sorts...)
	if len(list) > 0 {
		return list[0]
	}
	return nil
}

// SelectByModel selects by model
func (m *{{.Mapper.Name}}) SelectByModel(model *{{.Mapper.Model.Name}}) []*{{.Mapper.Model.Name}} {
	return m.SelectByModelAndSort(model, nil)
}

// SelectByModelAndSort selects by model with sort
func (m *{{.Mapper.Name}}) SelectByModelAndSort(model *{{.Mapper.Model.Name}}, sorts ...p.Sort) []*{{.Mapper.Model.Name}} {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	list := m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).Exec().List(new({{.Mapper.Model.Name}}))
	newList := make([]*{{.Mapper.Model.Name}}, len(list))
	for i := range list {
		newList[i] = list[i].(*{{.Mapper.Model.Name}})
	}
	return newList
}

// SelectByCond selects by cond
func (m *{{.Mapper.Name}}) SelectByCond(conds ...p.Cond) []*{{.Mapper.Model.Name}} {
	return m.SelectByCondAndSort(conds, nil)
}

// SelectByCondAndSort selects by cond with sort
func (m *{{.Mapper.Name}}) SelectByCondAndSort(conds []p.Cond, sorts ...p.Sort) []*{{.Mapper.Model.Name}} {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	list := m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).Exec().List(new({{.Mapper.Model.Name}}))
	newList := make([]*{{.Mapper.Model.Name}}, len(list))
	for i := range list {
		newList[i] = list[i].(*{{.Mapper.Model.Name}})
	}
	return newList
}

// SelectPageByModel selects page by model
func (m *{{.Mapper.Name}}) SelectPageByModel(model *{{.Mapper.Model.Name}}, offset, size int) *Page {
	return m.SelectPageByModelAndSort(model, offset, size, nil)
}

// SelectPageByModelAndSort selects page by model with sort
func (m *{{.Mapper.Name}}) SelectPageByModelAndSort(model *{{.Mapper.Model.Name}}, offset, size int, sorts ...p.Sort) *Page {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageByCond selects page by cond
func (m *{{.Mapper.Name}}) SelectPageByCond(conds []p.Cond, offset, size int) *Page {
	return m.SelectPageByCondAndSort(conds, offset, size, nil)
}

// SelectPageByCondAndSort selects page by cond with sort
func (m *{{.Mapper.Name}}) SelectPageByCondAndSort(conds []p.Cond, offset, size int, sorts ...p.Sort) *Page {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageMapByModel selects page map by model
func (m *{{.Mapper.Name}}) SelectPageMapByModel(model *{{.Mapper.Model.Name}}, offset, size int) *PageMap {
	return m.SelectPageMapByModelAndSort(model, offset, size, nil)
}

// SelectPageMapByModelAndSort selects page map by model with sort
func (m *{{.Mapper.Name}}) SelectPageMapByModelAndSort(model *{{.Mapper.Model.Name}}, offset, size int, sorts ...p.Sort) *PageMap {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).PageMap(offset, size)
}

// SelectPageMapByCond selects page map by cond
func (m *{{.Mapper.Name}}) SelectPageMapByCond(conds []p.Cond, offset, size int) *PageMap {
	return m.SelectPageMapByCondAndSort(conds, offset, size, nil)
}

// SelectPageMapByCondAndSort selects page map by cond with sort
func (m *{{.Mapper.Name}}) SelectPageMapByCondAndSort(conds []p.Cond, offset, size int, sorts ...p.Sort) *PageMap {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper().Params(
		NewParam("WHERE_SQL", whereSQL),
		NewParam("SORT_SQL", sortSQL),
	).Args(params...).PageMap(offset, size)
}

// generateWhereSQL
func (m *{{.Mapper.Name}}) generateWhereSQL(model *{{.Mapper.Model.Name}}) (string, []interface{}) {
    params := make([]interface{}, 0)
 	wheres := make([]string, 0)
 	if model != nil {
        {{range $i,$e := .Mapper.Model.Ids}}
        if model.{{$e.Name}} {{$e.OpName}} {{$e.OpVar}} {
            wheres = append(wheres, "t.{{$e.Column.Name}} = ?")
            params = append(params, model.{{$e.Name}})
        }
        {{end}}{{range $i,$e := .Mapper.Model.Fields}}
        if model.{{$e.Name}} {{$e.OpName}} {{$e.OpVar}} {
            wheres = append(wheres, "t.{{$e.Column.Name}} = ?")
            params = append(params, model.{{$e.Name}})
        }
        {{end}}
    }
    if len(wheres) <= 0 {
        return "", params
    }
 	return " AND " + strings.Join(wheres, " AND "), params
}

// generateSortSQL
func (m *{{.Mapper.Name}}) generateSortSQL(sorts ...p.Sort) string {
	sortSQLs := make([]string, 0)
	for _, sort := range sorts {
	    if sort != nil {
		    sortSQLs = append(sortSQLs, sort.SQL())
		}
	}
	if len(sortSQLs) <= 0 {
		return ""
	}
	return " ORDER BY " + strings.Join(sortSQLs, ",")
}

// generateCondSQL generate Cond SQL for Query
func (m *{{.Mapper.Name}}) generateCondSQL(conds ...p.Cond) (string, []interface{}) {
	params := make([]interface{}, 0)
	condSQLs := make([]string, 0)
	for _, cond := range conds {
	    if cond != nil {
            condSQL, condParams := cond.SQL()
            condSQLs = append(condSQLs, condSQL)
            params = append(params, condParams...)
		}
	}
	return strings.Join(condSQLs, " "), params
}

func init() {
    c.{{.Mapper.Batis}}.AddRaw({{.Mapper.Name}}XML)
}

var {{.Mapper.Name}}XML = `
<?xml version="1.0" encoding="UTF-8"?>
<batis-mapper binding="{{.Mapper.Model.Name}}">

    <update id="Insert">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES ({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}?, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}?{{end}})
    </update>

    <update id="DeleteByID">
        DELETE FROM {{.Mapper.Model.Table.Name}} WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}{{$e.Column.Name}} = ?{{end}}
    </update>

    <update id="UpdateByID">
        UPDATE {{.Mapper.Model.Table.Name}} AS t SET {{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}t.{{$e.Column.Name}} = ?{{end}} WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}t.{{$e.Column.Name}} = ?{{end}}
    </update>

    <select id="SelectByID">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}t.{{$e.Column.Name}} = ?{{end}}
    </select>

    <select id="SelectByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@ @SORT_SQL@
    </select>

    <select id="SelectPageByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@ @SORT_SQL@
    </select>

    <select id="SelectPageMapByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@ @SORT_SQL@
    </select>

</batis-mapper>`