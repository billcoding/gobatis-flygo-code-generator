package {{.Config.Config.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

import (
	ba "github.com/billcoding/gobatis"
	_ "github.com/go-sql-driver/mysql"
)

var {{.Config.Mapper.Batis}} = ba.Default()

func init() {
	{{.Config.Mapper.Batis}}.DSN("DSN")
}
