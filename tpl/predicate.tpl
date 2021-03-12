package {{.Config.Predicate.PKG}}

// @author {{.Config.Global.Author}}
{{if .Config.Global.Date}}// @since {{.Extra.Date}}{{end}}
{{if .Config.Global.Copyright}}// @created by {{.Config.Global.CopyrightContent}}{{end}}
{{if .Config.Global.Website}}// @repo {{.Config.Global.WebsiteContent}}{{end}}

const (
	Eq Type = iota
	NotEq
	Like
	NotLike
	Gt
	NotGt
	Lt
	NotLt
)

type Column string
type Type int8
type Predicate map[Column]Type