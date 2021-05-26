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

var {{.Mapper.VarName}} = &{{.Mapper.Name}}{}

{{if .Config.Model.Comment}}// {{.Mapper.Name}} {{.Mapper.Model.Table.Comment}} Mapper{{end}}
type {{.Mapper.Name}} struct {
	insertMapper        *UpdateMapper
	insertAllMapper     *UpdateMapper
    deleteByIDMapper    *UpdateMapper{{if eq .Mapper.Model.IdCount 1}}
    deleteByIDsMapper   *UpdateMapper{{end}}
    deleteByFieldMapper *UpdateMapper
	updateByIDMapper    *UpdateMapper
	selectByIDMapper    *SelectMapper
	selectByModelMapper *SelectMapper
}
{{if .Mapper.Model.IntId}}{{if lt .Mapper.Model.IdCount 2}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) (bool, int64) {
    return m.InsertWithTX(nil, model)
}

// Inserts inserts some record
func (m *{{.Mapper.Name}}) Inserts(models []*{{.Mapper.Model.Name}}) (bool, []int64) {
    return m.InsertsWithTX(nil, models)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) (bool, int64) {
    m.insertMapper.Args({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(m.insertMapper)
	} else {
	    err = m.insertMapper.Exec()
	}
	if err == nil {
		return true, m.insertMapper.InsertedId()
	}
	return false, 0
}

// InsertsWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertsWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) (bool, []int64) {
	insertedIDs := make([]int64, 0)
	insertedCount := 0
	for i := range models {
		if success, insertedID := m.InsertWithTX(TX, models[i]); success {
			insertedCount++
			insertedIDs = append(insertedIDs, insertedID)
		}
	}
	return insertedCount == len(models), insertedIDs
}{{end}}{{else}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) bool {
    return m.InsertWithTX(nil, model)
}

// Inserts inserts some record
func (m *{{.Mapper.Name}}) Inserts(models []*{{.Mapper.Model.Name}}) bool {
    return m.InsertsWithTX(nil, models)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) bool {
    insertMapper := m.insertMapper
    insertMapper.Args({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(insertMapper)
	} else {
	    err = insertMapper.Exec()
	}
	return err == nil
}

// InsertsWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertsWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) bool {
	insertedCount := 0
	for i := range models {
		if m.InsertWithTX(TX, models[i]) {
			insertedCount++
		}
	}
	return insertedCount == len(models)
}{{end}}

// InsertAll inserts some record
func (m *{{.Mapper.Name}}) InsertAll(models []*{{.Mapper.Model.Name}}) bool {
    return m.InsertAllWithTX(nil, models)
}

// InsertAllWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertAllWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) bool {
	args := make([]interface{}, 0)
	for _, model := range models {
		args = append(args{{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}, model.{{$e.Name}}{{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}, model.{{$e.Name}}{{end}})
	}
	m.insertAllMapper.Prepare(models).Args(args...)
    var err error
	if TX != nil {
	   TX.Update(m.insertAllMapper)
	} else {
	    err = m.insertAllMapper.Exec()
	}
	return err == nil
}

// DeleteByID deletes one record by ID
func (m *{{.Mapper.Name}}) DeleteByID({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}},{{end}}{{$e.Name}} {{$e.Type}}{{end}}) bool {
    return m.DeleteByIDWithTX(nil, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
}

// DeleteByIDWithTX deletes one record by ID with a tx
func (m *{{.Mapper.Name}}) DeleteByIDWithTX(TX *TX, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) bool {
    deleteByIDMapper := m.deleteByIDMapper.Args({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(deleteByIDMapper)
        return true
    }
    return deleteByIDMapper.Exec() == nil
}{{if eq .Mapper.Model.IdCount 1}}{{$id := (index .Mapper.Model.Ids 0)}}{{$idName := $id.Name}}{{$idType := $id.Type}}
// DeleteByIDs deletes some record by IDs
func (m *{{.Mapper.Name}}) DeleteByIDs({{ $idName }}s []{{ $idType }}) bool {
	return m.DeleteByIDsWithTX(nil, {{ $idName }}s)
}

// DeleteByIDsWithTX deletes some record by IDs with a tx
func (m *{{.Mapper.Name}}) DeleteByIDsWithTX(TX *TX, IDs []{{ $idType }}) bool {
	if IDs == nil || len(IDs) <= 0 {
		return false
	}
	args := make([]interface{}, 0)
	for i := range IDs {
		args = append(args, IDs[i])
	}
	deleteByIDsMapper := m.deleteByIDsMapper.Prepare(IDs).Args(args...)
	if TX != nil{
		TX.Update(deleteByIDsMapper)
		return true
	}
	return deleteByIDsMapper.Exec() == nil
}{{end}}{{$mapperName := .Mapper.Name}}{{if gt .Mapper.Model.IdCount 1}}{{range $i,$e := .Mapper.Model.Ids}}

// DeleteBy{{$e.Name}} deletes a record by {{$e.Name}}
func (m *{{$mapperName}}) DeleteBy{{$e.Name}}({{$e.Name}} {{$e.Type}}) bool {
	return m.DeleteBy{{$e.Name}}WithTX(nil, {{$e.Name}})
}

// DeleteBy{{$e.Name}}WithTX deletes a record by {{$e.Name}} with a tx
func (m *{{$mapperName}}) DeleteBy{{$e.Name}}WithTX(TX *TX, {{$e.Name}} {{$e.Type}}) bool {
	m.deleteByFieldMapper.Prepare("{{$e.Column.Name}}").Args({{$e.Name}})
	if TX != nil{
		TX.Update(m.deleteByFieldMapper)
		return true
	}
	return m.deleteByFieldMapper.Exec() == nil
}{{end}}{{end}}

// DeleteByField deletes a record by column
func (m *{{.Mapper.Name}}) DeleteByField(column p.Column, field interface{}) bool {
	return m.DeleteByFieldWithTX(nil, column, field)
}

// DeleteByFieldWithTX deletes a record by column with a tx
func (m *{{.Mapper.Name}}) DeleteByFieldWithTX(TX *TX, column p.Column, field interface{}) bool {
	m.deleteByFieldMapper.Prepare(column).Args(field)
	if TX != nil{
		TX.Update(m.deleteByFieldMapper)
		return true
	}
	return m.deleteByFieldMapper.Exec() == nil
}

// UpdateByID updates one record by ID
func (m *{{.Mapper.Name}}) UpdateByID(model *{{.Mapper.Model.Name}}) bool {
    return m.UpdateByIDWithTX(nil, model)
}

// UpdateByIDWithTX updates one record by ID with a tx
func (m *{{.Mapper.Name}}) UpdateByIDWithTX(TX *TX, model *{{.Mapper.Model.Name}}) bool {
    updateByIDMapper := m.updateByIDMapper.Args({{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}}{{range $i,$e := .Mapper.Model.Ids}}, model.{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(updateByIDMapper)
        return true
    }
    return updateByIDMapper.Exec() == nil
}

// SelectByID selects one record by ID
func (m *{{.Mapper.Name}}) SelectByID({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) *{{.Mapper.Model.Name}} {
	list := m.selectByIDMapper.Args({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}}).Exec().List(new({{.Mapper.Model.Name}}))
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
	list := m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Exec().List(new({{.Mapper.Model.Name}}))
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
	list := m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Exec().List(new({{.Mapper.Model.Name}}))
	newList := make([]*{{.Mapper.Model.Name}}, len(list))
	for i := range list {
		newList[i] = list[i].(*{{.Mapper.Model.Name}})
	}
	return newList
}

// SelectOneMapByModel selects one map by model
func (m *{{.Mapper.Name}}) SelectOneMapByModel(model *{{.Mapper.Model.Name}}) map[string]interface{} {
	return m.SelectOneMapByModelAndSort(model, nil)
}

// SelectOneMapByModelAndSort selects one map by model with sort
func (m *{{.Mapper.Name}}) SelectOneMapByModelAndSort(model *{{.Mapper.Model.Name}}, sorts ...p.Sort) map[string]interface{} {
	list := m.SelectMapByModelAndSort(model, sorts...)
	if len(list) > 0 {
		return list[0]
	}
	return nil
}

// SelectOneMapByCond selects one map by cond
func (m *{{.Mapper.Name}}) SelectOneMapByCond(conds ...p.Cond) map[string]interface{} {
	return m.SelectOneMapByCondAndSort(conds, nil)
}

// SelectOneMapByCondAndSort selects one map by cond with sort
func (m *{{.Mapper.Name}}) SelectOneMapByCondAndSort(conds []p.Cond, sorts ...p.Sort) map[string]interface{} {
	list := m.SelectMapByCondAndSort(conds, sorts...)
	if len(list) > 0 {
		return list[0]
	}
	return nil
}

// SelectMapByModel selects map by model
func (m *{{.Mapper.Name}}) SelectMapByModel(model *{{.Mapper.Model.Name}}) []map[string]interface{} {
	return m.SelectMapByModelAndSort(model, nil)
}

// SelectMapByModelAndSort selects map by model with sort
func (m *{{.Mapper.Name}}) SelectMapByModelAndSort(model *{{.Mapper.Model.Name}}, sorts ...p.Sort) []map[string]interface{} {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Exec().MapList()
}

// SelectMapByCond selects map by cond
func (m *{{.Mapper.Name}}) SelectMapByCond(conds ...p.Cond) []map[string]interface{} {
	return m.SelectMapByCondAndSort(conds, nil)
}

// SelectMapByCondAndSort selects map by cond with sort
func (m *{{.Mapper.Name}}) SelectMapByCondAndSort(conds []p.Cond, sorts ...p.Sort) []map[string]interface{} {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Exec().MapList()
}

// SelectPageByModel selects page by model
func (m *{{.Mapper.Name}}) SelectPageByModel(model *{{.Mapper.Model.Name}}, offset, size int) *Page {
	return m.SelectPageByModelAndSort(model, offset, size, nil)
}

// SelectPageByModelAndSort selects page by model with sort
func (m *{{.Mapper.Name}}) SelectPageByModelAndSort(model *{{.Mapper.Model.Name}}, offset, size int, sorts ...p.Sort) *Page {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageByCond selects page by cond
func (m *{{.Mapper.Name}}) SelectPageByCond(conds []p.Cond, offset, size int) *Page {
	return m.SelectPageByCondAndSort(conds, offset, size, nil)
}

// SelectPageByCondAndSort selects page by cond with sort
func (m *{{.Mapper.Name}}) SelectPageByCondAndSort(conds []p.Cond, offset, size int, sorts ...p.Sort) *Page {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageMapByModel selects page map by model
func (m *{{.Mapper.Name}}) SelectPageMapByModel(model *{{.Mapper.Model.Name}}, offset, size int) *PageMap {
	return m.SelectPageMapByModelAndSort(model, offset, size, nil)
}

// SelectPageMapByModelAndSort selects page map by model with sort
func (m *{{.Mapper.Name}}) SelectPageMapByModelAndSort(model *{{.Mapper.Model.Name}}, offset, size int, sorts ...p.Sort) *PageMap {
	whereSQL, params := m.generateWhereSQL(model)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).PageMap(offset, size)
}

// SelectPageMapByCond selects page map by cond
func (m *{{.Mapper.Name}}) SelectPageMapByCond(conds []p.Cond, offset, size int) *PageMap {
	return m.SelectPageMapByCondAndSort(conds, offset, size, nil)
}

// SelectPageMapByCondAndSort selects page map by cond with sort
func (m *{{.Mapper.Name}}) SelectPageMapByCondAndSort(conds []p.Cond, offset, size int, sorts ...p.Sort) *PageMap {
	whereSQL, params := m.generateCondSQL(conds...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).PageMap(offset, size)
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
    c.{{.Mapper.Batis}}.AddRaw({{.Mapper.Name}}XML){{$cBatis := .Mapper.Batis}}{{$varName := .Mapper.VarName}}{{$modelName := .Mapper.Model.Name}}
    {
    	{{.Mapper.VarName}}.insertMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "Insert").Update()
    	{{.Mapper.VarName}}.insertAllMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "InsertAll").Update()
    	{{.Mapper.VarName}}.deleteByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByID").Update(){{if eq .Mapper.Model.IdCount 1}}
    	{{.Mapper.VarName}}.deleteByIDsMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByIDs").Update(){{end}}
    	{{.Mapper.VarName}}.deleteByFieldMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByField").Update()
    	{{.Mapper.VarName}}.updateByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "UpdateByID").Update()
    	{{.Mapper.VarName}}.selectByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByID").Select()
    	{{.Mapper.VarName}}.selectByModelMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByModel").Select()
    }
}

var {{.Mapper.Name}}XML = `
<?xml version="1.0" encoding="UTF-8"?>
<batis-mapper binding="{{.Mapper.Model.Name}}">

    <update id="Insert">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES ({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}?, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}?{{end}})
    </update>

    <update id="InsertAll">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES {{ "{{ range $i,$e := . }}{{ if gt $i 0 }}, {{ end }}" }}({{if not .Mapper.Model.IntId}}{{range $i,$e := .Mapper.Model.Ids}}?, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}?{{end}}){{ "{{end}}" }}
    </update>

    <update id="DeleteByID">
        DELETE FROM {{.Mapper.Model.Table.Name}} WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}{{$e.Column.Name}} = ?{{end}}
    </update>
    {{if eq .Mapper.Model.IdCount 1}}
    <update id="DeleteByIDs">
		DELETE FROM {{.Mapper.Model.Table.Name}} WHERE {{ (index .Mapper.Model.Ids 0).Name }} IN ({{ "{{ range $i,$e := . }}{{if gt $i 0}}, {{end}}?{{end}}" }})
	</update>
	{{end}}
    <update id="DeleteByField">
		DELETE FROM {{.Mapper.Model.Table.Name}} WHERE {{ "{{.}}" }} = ?
	</update>
	
	<update id="UpdateByID">
        UPDATE {{.Mapper.Model.Table.Name}} AS t SET {{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}t.{{$e.Column.Name}} = ?{{end}} WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}t.{{$e.Column.Name}} = ?{{end}}
    </update>

    <select id="SelectByID">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}} AND {{end}}t.{{$e.Column.Name}} = ?{{end}}
    </select>

    <select id="SelectByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 {{ "{{.WHERE_SQL}}" }} {{ "{{.SORT_SQL}}" }}
    </select>

</batis-mapper>`