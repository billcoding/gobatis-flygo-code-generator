package generator

import (
	"fmt"
	. "github.com/billcoding/golang-code-generator/config"
	. "github.com/billcoding/golang-code-generator/model"
	. "github.com/billcoding/golang-code-generator/tpl"
	. "github.com/billcoding/golang-code-generator/util"
	"log"
	"os"
	"path/filepath"
	"time"
)

var controllerGeneratorLogger = log.New(os.Stdout, "[ControllerGenerator]", log.LstdFlags)

type ControllerGenerator struct {
	C          *Configuration
	Controller *Controller
	Body       string
}

func (cg *ControllerGenerator) Init(e *Model) {
	cg.Controller = &Controller{
		PKG:   cg.C.Controller.PKG,
		Model: e,
	}
	cg.Controller.Name = cg.C.Controller.NamePrefix + ConvertString(cg.Controller.Model.Table.Name, cg.C.Controller.NameStrategy) + cg.C.Controller.NameSuffix
	cg.Controller.Route = cg.C.Controller.RoutePrefix + ConvertString(cg.Controller.Model.Table.Name, cg.C.Controller.RouteStrategy) + cg.C.Controller.RouteSuffix
	cg.Controller.VarName = cg.C.Controller.VarNamePrefix + ConvertString(cg.Controller.Model.Table.Name, cg.C.Controller.VarNameStrategy) + cg.C.Controller.VarNameSuffix
	cg.Controller.FileName = ConvertString(cg.Controller.Model.Table.Name, cg.C.Controller.FileNameStrategy)
}

func (cg *ControllerGenerator) Generate() {
	cg.generateBody()
	cg.generateFile()
}

func (cg *ControllerGenerator) generateBody() {
	cg.Body = ExecuteTpl(ControllerTpl(), map[string]interface{}{
		"Controller": cg.Controller,
		"Config":     cg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(cg.C.Global.DateLayout),
		},
	})
	if cg.C.Verbose {
		controllerGeneratorLogger.Println(fmt.Sprintf("[generateBody] for model[%s]", cg.Controller.Model.Name))
	}
}

func (cg *ControllerGenerator) generateFile() {
	paths := make([]string, 0)
	paths = append(paths, cg.C.OutputDir)
	paths = append(paths, cg.C.Controller.PKG)
	paths = append(paths, cg.Controller.FileName)
	fileName := filepath.Join(paths...) + ".go"
	dir := filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(cg.Body), 0700)
	if cg.C.Verbose {
		controllerGeneratorLogger.Println(fmt.Sprintf("[generateFile] for model[%s], saved as [%s]", cg.Controller.Model.Name, fileName))
	}
}
