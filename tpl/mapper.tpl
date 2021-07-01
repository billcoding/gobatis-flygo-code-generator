package {{.Config.Mapper.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
	"embed"
    . "github.com/billcoding/gobatis"
    p "github.com/billcoding/gobatis/predicate"
    c "{{.Config.Module}}/{{.Config.Config.PKG}}"
    . "{{.Config.Module}}/{{.Mapper.Model.PKG}}"
    "strings"
)

var {{.Mapper.VarName}} = &{{.Mapper.Name}}{}

{{if .Config.Model.Comment}}// {{.Mapper.Name}} {{.Mapper.Model.Table.Comment}} Mapper{{end}}
type {{.Mapper.Name}} struct {
	insertMapper               *UpdateMapper
	insertAllMapper            *UpdateMapper
	insertAllPrepareMapper     *UpdateMapper
    deleteByIDMapper           *UpdateMapper{{if eq .Mapper.Model.IdCount 1}}
    deleteByIDsMapper          *UpdateMapper{{end}}
    deleteByFieldMapper        *UpdateMapper
    deleteByCondMapper         *UpdateMapper
	updateByIDMapper           *UpdateMapper
	selectByIDMapper           *SelectMapper
	selectByModelMapper        *SelectMapper
	selectCountByModelMapper   *SelectMapper
}
{{if .Mapper.Model.IntId}}{{if lt .Mapper.Model.IdCount 2}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) (error, int64) {
    return m.InsertWithTX(nil, model)
}

// Inserts inserts some record
func (m *{{.Mapper.Name}}) Inserts(models []*{{.Mapper.Model.Name}}) (error, []int64) {
    return m.InsertsWithTX(nil, models)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) (error, int64) {
    m.insertMapper.Args({{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(m.insertMapper)
	} else {
	    err = m.insertMapper.Exec()
	}
	return err, m.insertMapper.InsertedId()
}

// InsertsWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertsWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) (error, []int64) {
	insertedIDs := make([]int64, 0)
	for i := range models {
		if err, insertedID := m.InsertWithTX(TX, models[i]); err != nil {
			return err, insertedIDs
		}else {
			insertedIDs = append(insertedIDs, insertedID)
		}
	}
	return nil, insertedIDs
}{{end}}{{else}}
// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) error {
    return m.InsertWithTX(nil, model)
}

// Inserts inserts some record
func (m *{{.Mapper.Name}}) Inserts(models []*{{.Mapper.Model.Name}}) error {
    return m.InsertsWithTX(nil, models)
}

// InsertWithTX inserts one record with a tx
func (m *{{.Mapper.Name}}) InsertWithTX(TX *TX, model *{{.Mapper.Model.Name}}) error {
    insertMapper := m.insertMapper
    insertMapper.Args({{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}model.{{$e.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}})
    var err error
	if TX != nil {
	   TX.Update(insertMapper)
	} else {
	    err = insertMapper.Exec()
	}
	return err
}

// InsertsWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertsWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) error {
	for i := range models {
		if err := m.InsertWithTX(TX, models[i]); err != nil {
			return err
		}
	}
	return nil
}{{end}}

// InsertAll inserts some record
func (m *{{.Mapper.Name}}) InsertAll(models []*{{.Mapper.Model.Name}}) error {
    return m.InsertAllWithTX(nil, models)
}

// InsertAllWithTX inserts some record with a tx
func (m *{{.Mapper.Name}}) InsertAllWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) error {
	args := make([]interface{}, 0)
	for _, model := range models {
		args = append(args{{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}, model.{{$e.Name}}{{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}, model.{{$e.Name}}{{end}})
	}
	m.insertAllMapper.Prepare(models).Args(args...)
    var err error
	if TX != nil {
	   TX.Update(m.insertAllMapper)
	} else {
	    err = m.insertAllMapper.Exec()
	}
	return err
}

// InsertAllPrepare inserts some record by prepare
func (m *{{.Mapper.Name}}) InsertAllPrepare(models []*{{.Mapper.Model.Name}}) error {
    return m.InsertAllPrepareWithTX(nil, models)
}

// InsertAllPrepareWithTX inserts some record with a tx by prepare
func (m *{{.Mapper.Name}}) InsertAllPrepareWithTX(TX *TX, models []*{{.Mapper.Model.Name}}) error {
	m.insertAllPrepareMapper.Prepare(models)
    var err error
	if TX != nil {
	   TX.Update(m.insertAllPrepareMapper)
	} else {
	    err = m.insertAllPrepareMapper.Exec()
	}
	return err
}

// DeleteByID deletes one record by ID
func (m *{{.Mapper.Name}}) DeleteByID({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}},{{end}}{{$e.Name}} {{$e.Type}}{{end}}) error {
    return m.DeleteByIDWithTX(nil, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
}

// DeleteByIDWithTX deletes one record by ID with a tx
func (m *{{.Mapper.Name}}) DeleteByIDWithTX(TX *TX, {{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) error {
    deleteByIDMapper := m.deleteByIDMapper.Args({{range $i,$e := .Mapper.Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(deleteByIDMapper)
        return nil
    }
    return deleteByIDMapper.Exec()
}{{if eq .Mapper.Model.IdCount 1}}{{$id := (index .Mapper.Model.Ids 0)}}{{$idName := $id.Name}}{{$idType := $id.Type}}
// DeleteByIDs deletes some record by IDs
func (m *{{.Mapper.Name}}) DeleteByIDs({{ $idName }}s []{{ $idType }}) error {
	return m.DeleteByIDsWithTX(nil, {{ $idName }}s)
}

// DeleteByIDsWithTX deletes some record by IDs with a tx
func (m *{{.Mapper.Name}}) DeleteByIDsWithTX(TX *TX, IDs []{{ $idType }}) error {
	if IDs == nil || len(IDs) <= 0 {
		return nil
	}
	args := make([]interface{}, 0)
	for i := range IDs {
		args = append(args, IDs[i])
	}
	deleteByIDsMapper := m.deleteByIDsMapper.Prepare(IDs).Args(args...)
	if TX != nil{
		TX.Update(deleteByIDsMapper)
		return nil
	}
	return deleteByIDsMapper.Exec()
}{{end}}{{$mapperName := .Mapper.Name}}{{if gt .Mapper.Model.IdCount 1}}{{range $i,$e := .Mapper.Model.Ids}}

// DeleteBy{{$e.Name}} deletes a record by {{$e.Name}}
func (m *{{$mapperName}}) DeleteBy{{$e.Name}}({{$e.Name}} {{$e.Type}}) error {
	return m.DeleteBy{{$e.Name}}WithTX(nil, {{$e.Name}})
}

// DeleteBy{{$e.Name}}WithTX deletes a record by {{$e.Name}} with a tx
func (m *{{$mapperName}}) DeleteBy{{$e.Name}}WithTX(TX *TX, {{$e.Name}} {{$e.Type}}) error {
	m.deleteByFieldMapper.Prepare("{{$e.Column.Name}}").Args({{$e.Name}})
	if TX != nil{
		TX.Update(m.deleteByFieldMapper)
		return nil
	}
	return m.deleteByFieldMapper.Exec()
}{{end}}{{end}}

// DeleteByField deletes a record by column
func (m *{{.Mapper.Name}}) DeleteByField(column p.Column, field interface{}) error {
	return m.DeleteByFieldWithTX(nil, column, field)
}

// DeleteByFieldWithTX deletes a record by column with a tx
func (m *{{.Mapper.Name}}) DeleteByFieldWithTX(TX *TX, column p.Column, field interface{}) error {
	m.deleteByFieldMapper.Prepare(column).Args(field)
	if TX != nil{
		TX.Update(m.deleteByFieldMapper)
		return nil
	}
	return m.deleteByFieldMapper.Exec()
}

// DeleteByModel deletes some record by model
func (m *{{.Mapper.Name}}) DeleteByModel(model *{{.Mapper.Model.Name}}) error {
	return m.DeleteByModelWithTX(nil, model)
}

// DeleteByModelWithTX deletes some record by model with a tx
func (m *{{.Mapper.Name}}) DeleteByModelWithTX(TX *TX, model *{{.Mapper.Model.Name}}) error {
	whereSQL, params := m.generateWhereSQL(model, false)
	m.deleteByCondMapper.Prepare(whereSQL).Args(params...)
	if TX != nil{
		TX.Update(m.deleteByCondMapper)
		return nil
	}
	return m.deleteByCondMapper.Exec()
}

// DeleteByCond deletes some record by cs
func (m *{{.Mapper.Name}}) DeleteByCond(cs ...p.Cond) error {
	return m.DeleteByCondWithTX(nil, cs...)
}

// DeleteByCondWithTX deletes some record by cs with a tx
func (m *{{.Mapper.Name}}) DeleteByCondWithTX(TX *TX, cs ...p.Cond) error {
	condSQL, params := m.generateCondSQL(cs...)
	m.deleteByCondMapper.Prepare(condSQL).Args(params...)
	if TX != nil{
		TX.Update(m.deleteByCondMapper)
		return nil
	}
	return m.deleteByCondMapper.Exec()
}

// UpdateByID updates one record by ID
func (m *{{.Mapper.Name}}) UpdateByID(model *{{.Mapper.Model.Name}}) error {
    return m.UpdateByIDWithTX(nil, model)
}

// UpdateByIDWithTX updates one record by ID with a tx
func (m *{{.Mapper.Name}}) UpdateByIDWithTX(TX *TX, model *{{.Mapper.Model.Name}}) error {
    updateByIDMapper := m.updateByIDMapper.Args({{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}model.{{$e.Name}}{{end}}{{range $i,$e := .Mapper.Model.Ids}}, model.{{$e.Name}}{{end}})
    if TX != nil{
        TX.Update(updateByIDMapper)
        return nil
    }
    return updateByIDMapper.Exec()
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
func (m *{{.Mapper.Name}}) SelectOneByCond(cs ...p.Cond) *{{.Mapper.Model.Name}} {
	return m.SelectOneByCondAndSort(cs, nil)
}

// SelectOneByCondAndSort selects one by cond with sort
func (m *{{.Mapper.Name}}) SelectOneByCondAndSort(cs []p.Cond, sorts ...p.Sort) *{{.Mapper.Model.Name}} {
	list := m.SelectByCondAndSort(cs, sorts...)
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
	whereSQL, params := m.generateWhereSQL(model, true)
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
func (m *{{.Mapper.Name}}) SelectByCond(cs ...p.Cond) []*{{.Mapper.Model.Name}} {
	return m.SelectByCondAndSort(cs, nil)
}

// SelectByCondAndSort selects by cond with sort
func (m *{{.Mapper.Name}}) SelectByCondAndSort(cs []p.Cond, sorts ...p.Sort) []*{{.Mapper.Model.Name}} {
	whereSQL, params := m.generateCondSQL(cs...)
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
func (m *{{.Mapper.Name}}) SelectOneMapByCond(cs ...p.Cond) map[string]interface{} {
	return m.SelectOneMapByCondAndSort(cs, nil)
}

// SelectOneMapByCondAndSort selects one map by cond with sort
func (m *{{.Mapper.Name}}) SelectOneMapByCondAndSort(cs []p.Cond, sorts ...p.Sort) map[string]interface{} {
	list := m.SelectMapByCondAndSort(cs, sorts...)
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
	whereSQL, params := m.generateWhereSQL(model, true)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Exec().MapList()
}

// SelectMapByCond selects map by cond
func (m *{{.Mapper.Name}}) SelectMapByCond(cs ...p.Cond) []map[string]interface{} {
	return m.SelectMapByCondAndSort(cs, nil)
}

// SelectMapByCondAndSort selects map by cond with sort
func (m *{{.Mapper.Name}}) SelectMapByCondAndSort(cs []p.Cond, sorts ...p.Sort) []map[string]interface{} {
	whereSQL, params := m.generateCondSQL(cs...)
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
	whereSQL, params := m.generateWhereSQL(model, true)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageByCond selects page by cond
func (m *{{.Mapper.Name}}) SelectPageByCond(cs []p.Cond, offset, size int) *Page {
	return m.SelectPageByCondAndSort(cs, offset, size, nil)
}

// SelectPageByCondAndSort selects page by cond with sort
func (m *{{.Mapper.Name}}) SelectPageByCondAndSort(cs []p.Cond, offset, size int, sorts ...p.Sort) *Page {
	whereSQL, params := m.generateCondSQL(cs...)
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
	whereSQL, params := m.generateWhereSQL(model, true)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).PageMap(offset, size)
}

// SelectPageMapByCond selects page map by cond
func (m *{{.Mapper.Name}}) SelectPageMapByCond(cs []p.Cond, offset, size int) *PageMap {
	return m.SelectPageMapByCondAndSort(cs, offset, size, nil)
}

// SelectPageMapByCondAndSort selects page map by cond with sort
func (m *{{.Mapper.Name}}) SelectPageMapByCondAndSort(cs []p.Cond, offset, size int, sorts ...p.Sort) *PageMap {
	whereSQL, params := m.generateCondSQL(cs...)
	sortSQL := m.generateSortSQL(sorts...)
	return m.selectByModelMapper.Prepare(map[string]string{
		"WHERE_SQL": whereSQL,
		"SORT_SQL":  sortSQL,
	}).Args(params...).PageMap(offset, size)
}

// SelectCountByModel selects count by model
func (m *{{.Mapper.Name}}) SelectCountByModel(model *{{.Mapper.Model.Name}}) int64 {
	whereSQL, params := m.generateWhereSQL(model, true)
	return m.selectCountByModelMapper.Prepare(whereSQL).Args(params...).Exec().SingleInt()
}

// SelectCountByCond selects count by cond
func (m *{{.Mapper.Name}}) SelectCountByCond(cs ...p.Cond) int64 {
	whereSQL, params := m.generateCondSQL(cs...)
	return m.selectCountByModelMapper.Prepare(whereSQL).Args(params...).Exec().SingleInt()
}

// generateWhereSQL
func (m *{{.Mapper.Name}}) generateWhereSQL(model *{{.Mapper.Model.Name}}, prependAnd bool) (string, []interface{}) {
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
    prependSQL := ""
    if prependAnd {
    	prependSQL = " AND " 
    }
 	return prependSQL + strings.Join(wheres, " AND "), params
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
func (m *{{.Mapper.Name}}) generateCondSQL(cs ...p.Cond) (string, []interface{}) {
	params := make([]interface{}, 0)
	condSQLs := make([]string, 0)
	for _, cond := range cs {
	    if cond != nil {
            condSQL, condParams := cond.SQL()
            condSQLs = append(condSQLs, condSQL)
            params = append(params, condParams...)
		}
	}
	return strings.Join(condSQLs, " "), params
}


//go:embed xml/{{.Mapper.FileName}}.xml
var {{.Mapper.Name}}FS embed.FS

func init() {
    c.{{.Mapper.Batis}}.AddFS(&{{.Mapper.Name}}FS, "xml/{{.Mapper.FileName}}.xml"){{$cBatis := .Mapper.Batis}}{{$varName := .Mapper.VarName}}{{$modelName := .Mapper.Model.Name}}
    {
    	{{.Mapper.VarName}}.insertMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "Insert").Update()
    	{{.Mapper.VarName}}.insertAllMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "InsertAll").Update()
    	{{.Mapper.VarName}}.insertAllPrepareMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "InsertAllPrepare").Update()
    	{{.Mapper.VarName}}.deleteByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByID").Update(){{if eq .Mapper.Model.IdCount 1}}
    	{{.Mapper.VarName}}.deleteByIDsMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByIDs").Update(){{end}}
    	{{.Mapper.VarName}}.deleteByFieldMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByField").Update()
    	{{.Mapper.VarName}}.deleteByCondMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "DeleteByCond").Update()
    	{{.Mapper.VarName}}.updateByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "UpdateByID").Update()
    	{{.Mapper.VarName}}.selectByIDMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByID").Select()
    	{{.Mapper.VarName}}.selectByModelMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectByModel").Select()
    	{{.Mapper.VarName}}.selectCountByModelMapper = NewHelperWithBatis(c.{{.Mapper.Batis}}, "{{.Mapper.Model.Name}}", "SelectCountByModel").Select()
    }
}