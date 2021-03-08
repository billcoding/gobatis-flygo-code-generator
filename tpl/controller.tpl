package {{.Config.Controller.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
    . "github.com/billcoding/flygo"
    . "github.com/billcoding/flygo/context"
)

{{if .Config.Controller.Comment}}// {{.Controller.Name}} {{.Controller.Model.Table.Comment}} Controller{{end}}
type {{.Controller.Name}} struct {
}

func init() {
    app := GetApp()
    {{.Controller.VarName}} := &{{.Controller.Name}}{}
    app.REST({{.Controller.VarName}})
}

// Prefix returns route prefix
func (ctl *{{.Controller.Name}}) Prefix() string {
	return "{{.Controller.Route}}"
}

// GET return routed GET handler
func (ctl *{{.Controller.Name}}) GET() func(ctx *Context) {
	return func(c *Context) {
        c.Text("GET")
	}
}

// GETS return routed GETS handler
func (ctl *{{.Controller.Name}}) GETS() func(ctx *Context) {
	return func(c *Context) {
        c.Text("GETS")
	}
}

// POST return routed POST handler
func (ctl *{{.Controller.Name}}) POST() func(ctx *Context) {
	return func(c *Context) {
        c.Text("POST")
	}
}

// PUT return routed PUT handler
func (ctl *{{.Controller.Name}}) PUT() func(ctx *Context) {
	return func(c *Context) {
        c.Text("PUT")
	}
}

// DELETE return routed DELETE handler
func (ctl *{{.Controller.Name}}) DELETE() func(ctx *Context) {
	return func(c *Context) {
        c.Text("DELETE")
	}
}