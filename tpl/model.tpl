package {{.Config.Model.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
	"encoding/json"
    p "github.com/billcoding/gobatis/predicate"{{if .Model.ImportTime}}
    "time"
{{end}})

{{if .Config.Model.Comment}}// {{.Model.Name}} struct {{.Model.Table.Comment}}{{end}}
type {{.Model.Name}} struct {
    {{range $i, $e := .Model.Ids}}
    {{if $e.Comment}}// {{$e.Name}} {{$e.Column.Comment}}{{end}}
    {{$e.Name}} {{$e.Type}} `db:"{{$e.Column.Name}}"{{if $e.JSONTag}} json:"{{$e.JSONTagName}}"{{end}} generator:"DB_PRI"`
    {{end}}{{range $i, $e := .Model.Fields}}
    {{if $e.Comment}}// {{$e.Name}} {{$e.Column.Comment}}{{end}}
    {{$e.Name}} {{$e.Type}} `db:"{{$e.Column.Name}}"{{if $e.JSONTag}} json:"{{$e.JSONTagName}}"{{end}}`
    {{end}}
}

// New{{.Model.Name}} returns new {{.Model.Name}} pointer
func New{{.Model.Name}}({{if not .Model.IntId}}{{range $i,$e := .Model.Ids}}{{$e.Name}} {{$e.Type}}, {{end}}{{end}}{{range $i, $e := .Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}) *{{.Model.Name}} {
    m := &{{.Model.Name}}{}
    {{if not .Model.IntId}}{{range $i, $e := .Model.Ids}}
    m.{{$e.Name}} = {{$e.Name}}
    {{end}}{{end}}{{range $i, $e := .Model.Fields}}
    m.{{$e.Name}} = {{$e.Name}}
    {{end}}
    return m
}

// Default{{.Model.Name}} returns new {{.Model.Name}} with default valued fields pointer
func Default{{.Model.Name}}({{if not .Model.IntId}}{{range $i,$e := .Model.Ids}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}{{end}}{{if not .Model.IntId}}{{range $i, $e := .Model.NoDefaultFields}}, {{$e.Name}} {{$e.Type}}{{end}}{{else}}{{range $i, $e := .Model.NoDefaultFields}}{{if gt $i 0}}, {{end}}{{$e.Name}} {{$e.Type}}{{end}}{{end}}) *{{.Model.Name}} {
    m := &{{.Model.Name}}{}
    {{if not .Model.IntId}}{{range $i, $e := .Model.Ids}}
    m.{{$e.Name}} = {{$e.Name}}
    {{end}}{{end}}{{range $i, $e := .Model.NoDefaultFields}}
    m.{{$e.Name}} = {{$e.Name}}
    {{end}}{{range $i, $e := .Model.DefaultFields}}
    m.{{$e.Name}} = {{$e.Default}}
    {{end}}
    return m
}

// FieldMap model to map named with fields
func (model *{{.Model.Name}}) FieldMap() map[string]interface{} {
	return map[string]interface{}{
	    {{range $i, $e := .Model.Ids}}
        "{{$e.Name}}": model.{{$e.Name}},
        {{end}}{{range $i, $e := .Model.Fields}}
        "{{$e.Name}}": model.{{$e.Name}},
        {{end}}
    }
}

// ColumnMap model to map named with columns
func (model *{{.Model.Name}}) ColumnMap() map[string]interface{} {
	return map[string]interface{}{
	    {{range $i, $e := .Model.Ids}}
        "{{$e.Column.Name}}": model.{{$e.Name}},
        {{end}}{{range $i, $e := .Model.Fields}}
        "{{$e.Column.Name}}": model.{{$e.Name}},
        {{end}}
    }
}

// JSON model to json
func (model *{{.Model.Name}}) JSON() string {
	bytes, err := json.Marshal(model)
	if err != nil {
		panic(err)
	}
	return string(bytes)
}

var {{.Model.Name}}Columns = &struct{ {{range $i, $e := .Model.Ids}}
    {{if $e.Comment}}// {{$e.Name}} {{$e.Column.Comment}}{{end}}
    {{$e.Name}} p.Column
    {{end}}{{range $i, $e := .Model.Fields}}
    {{if $e.Comment}}// {{$e.Name}} {{$e.Column.Comment}}{{end}}
    {{$e.Name}} p.Column
    {{end}}
}{ {{range $i, $e := .Model.Ids}}
    {{$e.Name}} : "{{$e.Column.Name}}",
    {{end}}{{range $i, $e := .Model.Fields}}
    {{$e.Name}} : "{{$e.Column.Name}}",
{{end}}
}