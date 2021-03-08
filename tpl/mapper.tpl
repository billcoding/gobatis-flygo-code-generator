package {{.Config.Mapper.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
    . "github.com/billcoding/gobatis"
    . "{{.Config.Module}}/{{.Mapper.Model.PKG}}"
    c "{{.Config.Module}}/{{.Config.Config.PKG}}"
    "strings"
)

var {{.Mapper.VarName}} = &{{.Mapper.Name}}{
	insertMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "Insert").Update()
	},
	deleteByIDMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "DeleteByID").Update()
	},
	updateByIDMapper: func() *UpdateMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "UpdateByID").Update()
	},
	selectByIDMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "SelectByID").Select()
	},
	selectByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "SelectByModel").Select()
	},
	selectPageByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "SelectPageByModel").Select()
	},
	selectPageMapByModelMapper: func() *SelectMapper {
		return NewHelperWithBatis(c.Batis, "{{.Mapper.Model.Name}}", "SelectPageMapByModel").Select()
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

// Insert inserts one record
func (m *{{.Mapper.Name}}) Insert(model *{{.Mapper.Model.Name}}) (bool, int64) {
    return m.InsertWithTX(nil, model)
}

// Insert inserts one record with a tx
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

// SelectOneByModel selects one record by model
func (m *{{.Mapper.Name}}) SelectOneByModel(model *{{.Mapper.Model.Name}}) *{{.Mapper.Model.Name}} {
    list := m.SelectByModel(model)
    if len(list) > 0 {
        return list[0]
    }
    return nil
}

// SelectByModel selects records by model
func (m *{{.Mapper.Name}}) SelectByModel(model *{{.Mapper.Model.Name}}) []*{{.Mapper.Model.Name}} {
    whereSQL, params := m.generateWhereSQL(model)
	list := m.selectByModelMapper().Params(NewParam("WHERE_SQL", whereSQL)).Args(params...).Exec().List(new({{.Mapper.Model.Name}}))
	newList := make([]*{{.Mapper.Model.Name}}, len(list))
	for i := range list {
		newList[i] = list[i].(*{{.Mapper.Model.Name}})
	}
	return newList
}

// SelectPageByModel selects page by model
func (m *{{.Mapper.Name}}) SelectPageByModel(model *{{.Mapper.Model.Name}}, offset, size int) *Page {
    whereSQL, params := m.generateWhereSQL(model)
	return m.selectPageByModelMapper().Params(NewParam("WHERE_SQL", whereSQL)).Args(params...).Page(new({{.Mapper.Model.Name}}), offset, size)
}

// SelectPageMapByModel selects map page by model
func (m *{{.Mapper.Name}}) SelectPageMapByModel(model *{{.Mapper.Model.Name}}, offset, size int) *PageMap {
    whereSQL, params := m.generateWhereSQL(model)
	return m.selectPageMapByModelMapper().Params(NewParam("WHERE_SQL", whereSQL)).Args(params...).PageMap(offset, size)
}

// generateWhereSQL generate Where SQL for Query
func (m *{{.Mapper.Name}}) generateWhereSQL(model *{{.Mapper.Model.Name}}) (string, []interface{}) {
    params := make([]interface{}, 0)
 	wheres := make([]string, 0)
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
 	if len(wheres) <= 0 {
 	    return "", params
 	}
 	return " AND " + strings.Join(wheres, " AND "), params
}

func init() {
    c.Batis.AddRaw({{.Mapper.Name}}XML)
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
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@
    </select>

    <select id="SelectPageByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@
    </select>

    <select id="SelectPageMapByModel">
        SELECT t.* FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 @WHERE_SQL@
    </select>

</batis-mapper>`