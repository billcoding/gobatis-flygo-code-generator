package generator

import (
	"fmt"
	. "github.com/billcoding/gobatis-flygo-code-generator/config"
	. "github.com/billcoding/gobatis-flygo-code-generator/tpl"
	. "github.com/billcoding/gobatis-flygo-code-generator/util"
	"log"
	"os"
	"path/filepath"
	"time"
)

var predicateGeneratorLogger = log.New(os.Stdout, "[PredicateGenerator]", log.LstdFlags)

type PredicateGenerator struct {
	C    *Configuration
	Body string
}

func (cg *PredicateGenerator) Generate() {
	cg.generateBody()
	cg.generateFile()
}

func (cg *PredicateGenerator) generateBody() {
	cg.Body = ExecuteTpl(PredicateTpl(), map[string]interface{}{
		"Config": cg.C,
		"Extra": map[string]interface{}{
			"Date": time.Now().Format(cg.C.Global.DateLayout),
		},
	})
	if cg.C.Verbose {
		predicateGeneratorLogger.Println(fmt.Sprintf("[generateBody] for config[%s]", cg.C.Config.Name))
	}
}

func (cg *PredicateGenerator) generateFile() {
	paths := make([]string, 0)
	paths = append(paths, cg.C.OutputDir)
	paths = append(paths, cg.C.Predicate.PKG)
	paths = append(paths, cg.C.Predicate.Name)
	fileName := filepath.Join(paths...) + ".go"
	dir := filepath.Dir(fileName)
	_ = os.MkdirAll(dir, 0700)
	_ = os.WriteFile(fileName, []byte(cg.Body), 0700)
	if cg.C.Verbose {
		predicateGeneratorLogger.Println(fmt.Sprintf("[generateFile] for config[%s], saved as [%s]", cg.C.Config.Name, fileName))
	}
}
