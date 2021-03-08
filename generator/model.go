package generator

import (
	"fmt"
	. "github.com/billcoding/gobatis-flygo-code-generator/config"
	. "github.com/billcoding/gobatis-flygo-code-generator/model"
	"github.com/billcoding/gobatis-flygo-code-generator/tpl"
	. "github.com/billcoding/gobatis-flygo-code-generator/util"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

var modelGeneratorLogger = log.New(os.Stdout, "[ModelGenerator]", log.LstdFlags)

type ModelGenerator struct {
	C     *Configuration
	Table *Table
	Model *Model
	Body  string
}

func (eg *ModelGenerator) Generate() {
	eg.generateBody()
	eg.generateFile()
}

func (eg *ModelGenerator) Init() *ModelGenerator {
	eg.Model = &Model{
		PKG:             eg.C.Model.PKG,
		Table:           eg.Table,
		Ids:             make([]*Field, 0),
		Fields:          make([]*Field, 0),
		DefaultFields:   make([]*Field, 0),
		NoDefaultFields: make([]*Field, 0),
		Comment:         eg.C.Model.Comment,
	}
	eg.Model.Name = ConvertString(eg.Table.Name, eg.C.Model.TableToModelStrategy)
	eg.Model.FileName = ConvertString(eg.Table.Name, eg.C.Model.FileNameStrategy)
	for _, column := range eg.Table.Columns {
		field := &Field{
			Name:    ConvertString(column.Name, eg.C.Model.ColumnToFieldStrategy),
			Type:    MysqlToGoTypes[column.Type],
			Column:  column,
			Comment: eg.C.Model.FieldComment,
		}
		field.OpName = GoTypeOps[field.Type]
		field.OpVar = GoTypeOpVales[field.OpName]
		if column.ColumnKey == "PRI" {
			eg.Model.HaveId = true
			eg.Model.Ids = append(eg.Model.Ids, field)
		} else {
			eg.Model.Fields = append(eg.Model.Fields, field)
		}
		if column.Default != "__NULL__" {
			field.HaveDefault = true
			field.Default = column.Default
			switch {
			case field.Default == "CURRENT_TIMESTAMP" && field.Type == "string":
				field.Default = `time.Now().Format("2006-01-02 15:04:05")`
				eg.Model.ImportTime = true
			case field.Type == "string":
				field.Default = fmt.Sprintf("\"%s\"", field.Default)
			}
		}
		if eg.C.Model.FieldIdUpper {
			switch {
			case strings.LastIndex(field.Name, "Id") != -1:
				field.Name = strings.TrimSuffix(field.Name, "Id") + "ID"
			case strings.LastIndex(field.Name, "id") != -1:
				field.Name = strings.TrimSuffix(field.Name, "id") + "ID"
			}
		}
		if eg.C.Model.JSONTag {
			field.JSONTag = true
			field.JSONTagName = ConvertString(column.Name, eg.C.Model.JSONTagStrategy)
		}
	}

	for _, field := range eg.Model.Fields {
		if field.HaveDefault {
			eg.Model.DefaultFields = append(eg.Model.DefaultFields, field)
		} else {
			eg.Model.NoDefaultFields = append(eg.Model.NoDefaultFields, field)
		}
	}

	if !eg.Model.HaveId {
		panic(fmt.Sprintf("Table of [%s] required at least one PRI column", eg.Model.Table.Name))
	}
	eg.Model.IntId = strings.HasPrefix(eg.Model.Ids[0].Type, "int")
	return eg
}

func (eg *ModelGenerator) generateBody() {
	eg.Body = ExecuteTpl(tpl.ModelTpl(), map[string]interface{}{
		"Model":  eg.Model,
		"Config": eg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(eg.C.Global.DateLayout),
		},
	})
	if eg.C.Verbose {
		modelGeneratorLogger.Println(fmt.Sprintf("[generateBody] for model[%s]", eg.Model.Name))
	}
}

func (eg *ModelGenerator) generateFile() {
	paths := make([]string, 0)
	paths = append(paths, eg.C.OutputDir)
	paths = append(paths, eg.Model.PKG)
	paths = append(paths, eg.Model.FileName)
	fileName := filepath.Join(paths...) + ".go"
	dir := filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(eg.Body), 0700)
	if eg.C.Verbose {
		modelGeneratorLogger.Println(fmt.Sprintf("[generateFile] for model[%s], saved as [%s]", eg.Model.Name, fileName))
	}
}
