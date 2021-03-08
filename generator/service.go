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

var serviceGeneratorLogger = log.New(os.Stdout, "[ServiceGenerator]", log.LstdFlags)

type ServiceGenerator struct {
	C       *Configuration
	Service *Service
	Body    string
}

func (sg *ServiceGenerator) Init(e *Model) {
	sg.Service = &Service{
		PKG:   sg.C.Service.PKG,
		Model: e,
	}
	sg.Service.Name = sg.C.Service.NamePrefix + ConvertString(sg.Service.Model.Table.Name, sg.C.Service.NameStrategy) + sg.C.Service.NameSuffix
	sg.Service.VarName = sg.C.Service.VarNamePrefix + ConvertString(sg.Service.Model.Table.Name, sg.C.Service.VarNameStrategy) + sg.C.Service.VarNameSuffix
	sg.Service.FileName = ConvertString(sg.Service.Model.Table.Name, sg.C.Service.FileNameStrategy)
}

func (sg *ServiceGenerator) Generate() {
	sg.generateBody()
	sg.generateFile()
}

func (sg *ServiceGenerator) generateBody() {
	sg.Body = ExecuteTpl(ServiceTpl(), map[string]interface{}{
		"Service": sg.Service,
		"Config":  sg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(sg.C.Global.DateLayout),
		},
	})
	if sg.C.Verbose {
		serviceGeneratorLogger.Println(fmt.Sprintf("[generateBody] for model[%s]", sg.Service.Model.Name))
	}
}

func (sg *ServiceGenerator) generateFile() {
	paths := make([]string, 0)
	paths = append(paths, sg.C.OutputDir)
	paths = append(paths, sg.C.Service.PKG)
	paths = append(paths, sg.Service.FileName)
	fileName := filepath.Join(paths...) + ".go"
	dir := filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(sg.Body), 0700)
	if sg.C.Verbose {
		serviceGeneratorLogger.Println(fmt.Sprintf("[generateFile] for model[%s], saved as [%s]", sg.Service.Model.Name, fileName))
	}
}
