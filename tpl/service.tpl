package {{.Config.Service.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

var {{.Service.VarName}} = &{{.Service.Name}}{}

{{if .Config.Service.Comment}}// {{.Service.Model.Table.Comment}} Service{{end}}
type {{.Service.Name}} struct {
}

// DoService demo do service
func (s *{{.Service.Name}}) DoService() {

}