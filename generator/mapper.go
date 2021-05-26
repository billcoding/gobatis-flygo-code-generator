package generator

import (
	"fmt"
	. "github.com/billcoding/gobatis-flygo-code-generator/config"
	. "github.com/billcoding/gobatis-flygo-code-generator/model"
	. "github.com/billcoding/gobatis-flygo-code-generator/tpl"
	. "github.com/billcoding/gobatis-flygo-code-generator/util"
	"log"
	"os"
	"path/filepath"
	"time"
)

var mapperGeneratorLogger = log.New(os.Stdout, "[MapperGenerator]", log.LstdFlags)

type MapperGenerator struct {
	C      *Configuration
	Mapper *Mapper
	Body   string
	XML    string
}

func (mg *MapperGenerator) Init(e *Model) {
	mg.Mapper = &Mapper{
		PKG:   mg.C.Mapper.PKG,
		Model: e,
		Batis: mg.C.Mapper.Batis,
	}
	mg.Mapper.Name = mg.C.Mapper.NamePrefix + ConvertString(mg.Mapper.Model.Table.Name, mg.C.Mapper.NameStrategy) + mg.C.Mapper.NameSuffix
	mg.Mapper.VarName = mg.C.Mapper.VarNamePrefix + ConvertString(mg.Mapper.Model.Table.Name, mg.C.Mapper.VarNameStrategy) + mg.C.Mapper.VarNameSuffix
	mg.Mapper.FileName = ConvertString(mg.Mapper.Model.Table.Name, mg.C.Mapper.FileNameStrategy)
}

func (mg *MapperGenerator) Generate() {
	mg.generateBody()
	mg.generateFile()
}

func (mg *MapperGenerator) generateBody() {
	mg.Body = ExecuteTpl(MapperTpl(), map[string]interface{}{
		"Mapper": mg.Mapper,
		"Config": mg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(mg.C.Global.DateLayout),
		},
	})
	mg.XML = ExecuteTpl(XMLTpl(), map[string]interface{}{
		"Mapper": mg.Mapper,
		"Config": mg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(mg.C.Global.DateLayout),
		},
	})
	if mg.C.Verbose {
		mapperGeneratorLogger.Println(fmt.Sprintf("[generateBody] for model[%s]", mg.Mapper.Model.Name))
	}
}

func (mg *MapperGenerator) generateFile() {
	paths := make([]string, 0)
	paths = append(paths, mg.C.OutputDir)
	paths = append(paths, mg.Mapper.PKG)
	paths = append(paths, mg.Mapper.FileName)
	fileName := filepath.Join(paths...) + ".go"
	dir := filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(mg.Body), 0700)

	if mg.C.Verbose {
		mapperGeneratorLogger.Println(fmt.Sprintf("[generateFile] for model[%s], saved as [%s]", mg.Mapper.Model.Name, fileName))
	}

	paths = make([]string, 0)
	paths = append(paths, mg.C.OutputDir)
	paths = append(paths, mg.Mapper.PKG)
	paths = append(paths, "xml")
	paths = append(paths, mg.Mapper.FileName)
	fileName = filepath.Join(paths...) + ".xml"
	dir = filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(mg.XML), 0700)

	if mg.C.Verbose {
		mapperGeneratorLogger.Println(fmt.Sprintf("[generateXMLFile] for model[%s], saved as [%s]", mg.Mapper.Model.Name, fileName))
	}
}
