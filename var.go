package main

import (
	"flag"
	. "github.com/billcoding/gobatis-flygo-code-generator/config"
	"log"
	"os"
	"strings"
)

var (
	version       = flag.Bool("v", false, "The version info")
	help          = flag.Bool("h", false, "The help info")
	module        = flag.String("mod", "", "The project module name")
	outputDir     = flag.String("o", "", "The output dir")
	dsn           = flag.String("dsn", "root:123@tcp(127.0.0.1:3306)/test", "The MySQL DSN")
	database      = flag.String("db", "", "The Database name")
	includeTables = flag.String("git", "", "The include table names[table_a,table_b]")
	excludeTables = flag.String("get", "", "The exclude table names[table_a,table_b]")
	author        = flag.String("au", "bill", "The file copyright author")
	verbose       = flag.Bool("vb", false, "The verbose detail show?")

	model                      = flag.Bool("mo", true, "The model enable?")
	modelPKG                   = flag.String("mop", "model", "The model PKG")
	modelTableToModelStrategy  = flag.Int("motes", 3, "The table to model name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	modelColumnToFieldStrategy = flag.Int("mocfs", 3, "The column to field name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	modelFileNameStrategy      = flag.Int("mofns", 0, "The table to model Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	modelComment               = flag.Bool("moc", true, "The model comment generated?")
	modelFieldComment          = flag.Bool("mofc", true, "The model field comment generated?")
	modelJSONTag               = flag.Bool("mojt", true, "The model field JSON tag generated?")
	modelJSONTagStrategy       = flag.Int("mojts", 0, "The column to field name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")

	mapper                 = flag.Bool("ma", false, "The Mapper enable?")
	mapperPKG              = flag.String("map", "mapper", "The Mapper PKG")
	mapperNameStrategy     = flag.Int("mans", 2, "The table to Mapper var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	mapperVarStrategy      = flag.Int("mavs", 3, "The table to Mapper var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	mapperFileNameStrategy = flag.Int("mafns", 0, "The table to Mapper Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	mapperNamePrefix       = flag.String("manpx", "", "The Mapper name prefix")
	mapperNameSuffix       = flag.String("mansx", "Mapper", "The Mapper name suffix")
	mapperVarNamePrefix    = flag.String("mavnp", "", "The Mapper var name prefix")
	mapperVarNameSuffix    = flag.String("mavns", "Mapper", "The Mapper var name suffix")
	mapperComment          = flag.Bool("mac", true, "The Mapper comment?")
	mapperBatis            = flag.String("mab", "Batis", "The Mapper Batis name")

	config        = flag.Bool("cf", false, "The Config enable?")
	configPKG     = flag.String("cfp", "config", "The Config PKG")
	configComment = flag.Bool("cfc", true, "The Config comment?")

	controller                 = flag.Bool("c", false, "The Controller enable?")
	controllerPKG              = flag.String("cp", "controller", "The Controller PKG")
	controllerNameStrategy     = flag.Int("cns", 3, "The table to Controller var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	controllerVarStrategy      = flag.Int("cvs", 2, "The table to Controller var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	controllerRouteStrategy    = flag.Int("crs", 0, "The table to Controller route strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	controllerFileNameStrategy = flag.Int("cfns", 0, "The table to Controller Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	controllerNamePrefix       = flag.String("cnpx", "", "The Controller name prefix")
	controllerNameSuffix       = flag.String("cnsx", "Controller", "The Controller name suffix")
	controllerRoutePrefix      = flag.String("crpx", "/", "The Controller route prefix")
	controllerRouteSuffix      = flag.String("crsx", "", "The Controller route suffix")
	controllerVarNamePrefix    = flag.String("cvnp", "", "The Controller var name prefix")
	controllerVarNameSuffix    = flag.String("cvns", "Controller", "The Controller var name suffix")
	controllerComment          = flag.Bool("cc", true, "The Controller comment?")

	service                 = flag.Bool("se", false, "The Service enable?")
	servicePKG              = flag.String("sep", "service", "The Service PKG")
	serviceNameStrategy     = flag.Int("sens", 2, "The table to Service var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	serviceVarStrategy      = flag.Int("sevs", 3, "The table to Service var name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	serviceFileNameStrategy = flag.Int("sefns", 0, "The table to Service Go file name strategy[0: None,1: OnlyFirstLetterUpper,2: UnderlineToCamel,3: UnderlineToUpper]")
	serviceNamePrefix       = flag.String("senpx", "", "The Service name prefix")
	serviceNameSuffix       = flag.String("sensx", "Service", "The Service name suffix")
	serviceVarNamePrefix    = flag.String("sevnp", "", "The Service var name prefix")
	serviceVarNameSuffix    = flag.String("sevns", "Service", "The Service var name suffix")
	serviceComment          = flag.Bool("sec", true, "The Service comment?")
)

var logger = log.New(os.Stdout, "[gobatis-flygo-code-generator]", log.LstdFlags)

var CFG = &Configuration{
	Module:        "",
	OutputDir:     "",
	Verbose:       false,
	IncludeTables: make([]string, 0),
	ExcludeTables: make([]string, 0),
	Global: &GlobalConfiguration{
		Author:           "bill",
		Date:             true,
		DateLayout:       "2006-01-02",
		Copyright:        true,
		CopyrightContent: "gobatis & flygo code generator written by Golang",
		Website:          true,
		WebsiteContent:   "https://github.com/billcoding/gobatis-flygo-code-generator",
	},
	Model: &ModelConfiguration{
		PKG:                   "model",
		TableToModelStrategy:  UnderlineToCamel,
		ColumnToFieldStrategy: UnderlineToUpper,
		FileNameStrategy:      None,
		JSONTag:               true,
		JSONTagStrategy:       None,
		FieldIdUpper:          true,
		Comment:               true,
		FieldComment:          true,
		NamePrefix:            "",
		NameSuffix:            "",
	},
	Mapper: &MapperConfiguration{
		PKG:              "mapper",
		NameStrategy:     UnderlineToCamel,
		VarNameStrategy:  UnderlineToUpper,
		FileNameStrategy: None,
		NamePrefix:       "",
		NameSuffix:       "Mapper",
		VarNamePrefix:    "",
		VarNameSuffix:    "Mapper",
		Comment:          true,
		Batis:            "Batis",
	},
	Config: &CfgConfiguration{
		PKG:     "config",
		Name:    "config",
		Comment: true,
	},
	Controller: &ControllerConfiguration{
		PKG:              "controller",
		NameStrategy:     UnderlineToUpper,
		VarNameStrategy:  UnderlineToCamel,
		RouteStrategy:    None,
		FileNameStrategy: None,
		NamePrefix:       "",
		NameSuffix:       "Controller",
		RoutePrefix:      "/",
		RouteSuffix:      "",
		VarNamePrefix:    "",
		VarNameSuffix:    "Controller",
		Comment:          true,
	},
	Service: &ServiceConfiguration{
		PKG:              "service",
		NameStrategy:     UnderlineToUpper,
		VarNameStrategy:  UnderlineToCamel,
		FileNameStrategy: None,
		NamePrefix:       "",
		NameSuffix:       "Service",
		VarNamePrefix:    "",
		VarNameSuffix:    "Service",
		Comment:          true,
	},
}

func setCFG() {
	if *outputDir != "" {
		CFG.OutputDir = *outputDir
	}
	if CFG.OutputDir == "" {
		exec, err := os.Getwd()
		if err != nil {
			panic(err)
		}
		CFG.OutputDir = exec
	}
	if *module != "" {
		CFG.Module = *module
	}
	if *includeTables != "" {
		CFG.IncludeTables = strings.Split(*includeTables, ",")
	} else if *excludeTables != "" {
		CFG.ExcludeTables = strings.Split(*excludeTables, ",")
	}

	if *author != "" {
		CFG.Global.Author = *author
	}

	strategyTypeMap := map[int]StrategyType{
		0: None,
		1: OnlyFirstLetterUpper,
		2: UnderlineToCamel,
		3: UnderlineToUpper,
	}

	{
		if *modelPKG != "" {
			CFG.Model.PKG = *modelPKG
		}
		s1, have1 := strategyTypeMap[*modelTableToModelStrategy]
		if have1 {
			CFG.Model.TableToModelStrategy = s1
		}
		s2, have2 := strategyTypeMap[*modelColumnToFieldStrategy]
		if have2 {
			CFG.Model.ColumnToFieldStrategy = s2
		}
		CFG.Model.Comment = *modelComment
		CFG.Model.FieldComment = *modelFieldComment
		CFG.Model.JSONTag = *modelJSONTag
		s3, have3 := strategyTypeMap[*modelJSONTagStrategy]
		if have3 {
			CFG.Model.JSONTagStrategy = s3
		}
		s4, have4 := strategyTypeMap[*modelFileNameStrategy]
		if have4 {
			CFG.Model.FileNameStrategy = s4
		}
	}

	{
		if *mapperPKG != "" {
			CFG.Mapper.PKG = *mapperPKG
		}
		CFG.Mapper.NamePrefix = *mapperNamePrefix
		CFG.Mapper.NameSuffix = *mapperNameSuffix
		CFG.Mapper.VarNamePrefix = *mapperVarNamePrefix
		CFG.Mapper.VarNameSuffix = *mapperVarNameSuffix
		CFG.Mapper.Comment = *mapperComment
		CFG.Mapper.Batis = *mapperBatis
		s5, have5 := strategyTypeMap[*mapperFileNameStrategy]
		if have5 {
			CFG.Mapper.FileNameStrategy = s5
		}
		s6, have6 := strategyTypeMap[*mapperNameStrategy]
		if have6 {
			CFG.Mapper.NameStrategy = s6
		}
		s7, have7 := strategyTypeMap[*mapperVarStrategy]
		if have7 {
			CFG.Mapper.VarNameStrategy = s7
		}
	}

	{
		if *configPKG != "" {
			CFG.Config.PKG = *configPKG
		}
		CFG.Config.Comment = *configComment
	}

	{
		if *controllerPKG != "" {
			CFG.Controller.PKG = *controllerPKG
		}
		CFG.Controller.NamePrefix = *controllerNamePrefix
		CFG.Controller.NameSuffix = *controllerNameSuffix
		CFG.Controller.RoutePrefix = *controllerRoutePrefix
		CFG.Controller.RouteSuffix = *controllerRouteSuffix
		CFG.Controller.VarNamePrefix = *controllerVarNamePrefix
		CFG.Controller.VarNameSuffix = *controllerVarNameSuffix
		CFG.Controller.Comment = *controllerComment
		s5, have5 := strategyTypeMap[*controllerFileNameStrategy]
		if have5 {
			CFG.Controller.FileNameStrategy = s5
		}
		s6, have6 := strategyTypeMap[*controllerNameStrategy]
		if have6 {
			CFG.Controller.NameStrategy = s6
		}
		s7, have7 := strategyTypeMap[*controllerVarStrategy]
		if have7 {
			CFG.Controller.VarNameStrategy = s7
		}
		s8, have8 := strategyTypeMap[*controllerRouteStrategy]
		if have8 {
			CFG.Controller.RouteStrategy = s8
		}
	}

	{
		if *servicePKG != "" {
			CFG.Service.PKG = *servicePKG
		}
		CFG.Service.NamePrefix = *serviceNamePrefix
		CFG.Service.NameSuffix = *serviceNameSuffix
		CFG.Service.VarNamePrefix = *serviceVarNamePrefix
		CFG.Service.VarNameSuffix = *serviceVarNameSuffix
		CFG.Service.Comment = *serviceComment
		s5, have5 := strategyTypeMap[*serviceFileNameStrategy]
		if have5 {
			CFG.Service.FileNameStrategy = s5
		}
		s6, have6 := strategyTypeMap[*serviceNameStrategy]
		if have6 {
			CFG.Service.NameStrategy = s6
		}
		s7, have7 := strategyTypeMap[*serviceVarStrategy]
		if have7 {
			CFG.Service.VarNameStrategy = s7
		}
	}
}
