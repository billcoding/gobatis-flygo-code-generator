<?xml version="1.0" encoding="UTF-8"?>
<batis-mapper binding="{{.Mapper.Model.Name}}">

    <update id="Insert">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.AutoIncrement }}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES ({{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}?, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}?{{end}})
    </update>

    <update id="InsertAll">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.AutoIncrement }}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES {{ "{{range $i,$e := .}}{{if gt $i 0}}, {{end}}"}}({{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}?, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}?{{end}}){{"{{end}}"}}
    </update>

    <update id="InsertAllPrepare">
        INSERT INTO {{.Mapper.Model.Table.Name}}({{if not .Mapper.Model.AutoIncrement }}{{range $i,$e := .Mapper.Model.Ids}}{{$e.Column.Name}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{$e.Column.Name}}{{end}}) VALUES {{ "{{range $i,$e := .}}{{if gt $i 0}}, {{end}}"}}({{if not .Mapper.Model.AutoIncrement}}{{range $i,$e := .Mapper.Model.Ids}}{{"'{{$e."}}{{$e.Name}}{{"}}'"}}, {{end}}{{end}}{{range $i,$e := .Mapper.Model.Fields}}{{if gt $i 0}}, {{end}}{{"'{{$e."}}{{$e.Name}}{{"}}'"}}{{end}}){{"{{end}}"}}
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

    <update id="DeleteByCond">
		DELETE t.* FROM {{.Mapper.Model.Table.Name}} as t WHERE 1 = 1 {{ "{{.}}" }}
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

    <select id="SelectCountByModel">
        SELECT count(0) FROM {{.Mapper.Model.Table.Name}} AS t WHERE 1 = 1 {{ "{{.}}" }}
    </select>

</batis-mapper>