package cmd

import (
	"fmt"
	. "github.com/billcoding/golang-code-generator/bundle"
	. "github.com/billcoding/golang-code-generator/config"
	. "github.com/billcoding/golang-code-generator/generator"
	"github.com/spf13/cobra"
	"os"
	"strings"
)

var genCmd = &cobra.Command{
	Use:     "gen",
	Aliases: []string{"g", "generate"},
	Short:   "Generate Go files",
	Long: `Generate Go files.
Simply type golang-code-generator help gen for full details.`,
	Example: `golang-code-generator -D "root:123@tcp(127.0.0.1:3306)/test" -d "database" -M "awesome"
golang-code-generator -D "root:123@tcp(127.0.0.1:3306)/test" -d "database" -M "awesome" -o "/to/path" 
golang-code-generator -D "root:123@tcp(127.0.0.1:3306)/test" -d "database" -M "awesome" -au "bigboss" -o "/to/path"`,
	Run: func(cmd *cobra.Command, args []string) {
		CFG.Verbose = verbose

		if dsn == "" {
			fmt.Fprintln(os.Stderr, "The DSN is required")
			return
		}

		if module == "" {
			fmt.Fprintln(os.Stderr, "The Module name is required")
			return
		}

		if database == "" {
			fmt.Fprintln(os.Stderr, "The Database name is required")
			return
		}

		if !model {
			fmt.Fprintln(os.Stderr, "Nothing do...")
			return
		}

		Init(dsn)
		setCFG()

		tableList := Tables(database, CFG)
		columnList := Columns(database)
		tableMap := TransformTables(tableList)
		columnMap := TransformColumns(columnList)
		SetTableColumns(tableMap, columnMap)
		generators := make([]Generator, 0)

		modelGenerators := GetModelGenerators(CFG, tableMap)
		generators = append(generators, modelGenerators...)

		if mapper {
			mapperGenerators := GetMapperGenerators(CFG, modelGenerators)
			generators = append(generators, mapperGenerators...)
		}

		if config {
			generators = append(generators, GetCfgGenerator(CFG))
		}

		if controller {
			controllerGenerators := GetControllerGenerators(CFG, modelGenerators)
			generators = append(generators, controllerGenerators...)
		}

		if service {
			serviceGenerators := GetServiceGenerators(CFG, modelGenerators)
			generators = append(generators, serviceGenerators...)
		}

		for _, g := range generators {
			g.Generate()
		}
	},
}

func init() {
	genCmd.PersistentFlags().StringVarP(&outputDir, "output-dir", "o", "", "The output dir")
	genCmd.PersistentFlags().StringVarP(&dsn, "dsn", "D", "", "The MySQL DSN")
	genCmd.PersistentFlags().StringVarP(&database, "db", "d", "", "The Database name")
	genCmd.PersistentFlags().StringVarP(&module, "module", "M", "", "The Module name")
	genCmd.PersistentFlags().StringVarP(&includeTable, "include-table", "I", "", "The include table names[table_a,table_b]")
	genCmd.PersistentFlags().StringVarP(&excludeTable, "exclude-table", "E", "", "The exclude table names[table_a,table_b]")
	genCmd.PersistentFlags().StringVar(&author, "author", "bill", "The file copyright author")
	genCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "V", false, "Print verbose output")

	genCmd.PersistentFlags().BoolVar(&model, "model", true, "Generate Model Go file")
	genCmd.PersistentFlags().StringVarP(&modelPKG, "model-pkg", "1", "model", "The Model package")
	genCmd.PersistentFlags().BoolVar(&modelTable2ModelDefault, "table2model-default", false, "The Table to Model name strategy: default")
	genCmd.PersistentFlags().BoolVar(&modelTable2ModelFirstLetterUpper, "table2model-first-letter-upper", false, "The Table to Model name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&modelTable2ModelUnderlineToCamel, "table2model-underline-to-camel", false, "The Table to Model name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&modelTable2ModelUnderlineToUpper, "table2model-underline-to-upper", true, "The Table to Model name strategy: UnderlineToUpper")
	genCmd.PersistentFlags().BoolVar(&modelColumn2FieldDefault, "column2field-default", false, "The column to field name strategy: default")
	genCmd.PersistentFlags().BoolVar(&modelColumn2FieldFirstLetterUpper, "column2field-first-letter-upper", false, "The column to field name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&modelColumn2FieldUnderlineToCamel, "column2field-underline-to-camel", true, "The column to field name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&modelColumn2FieldUnderlineToUpper, "column2field-underline-to-upper", false, "The column to field name strategy: UnderlineToUpper")
	genCmd.PersistentFlags().BoolVar(&modelFileNameDefault, "model-filename-default", false, "The Model file name strategy: default")
	genCmd.PersistentFlags().BoolVar(&modelFileNameFirstLetterUpper, "model-filename-first-letter-upper", false, "The Model file name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&modelFileNameUnderlineToCamel, "model-filename-underline-to-camel", true, "The Model file name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&modelFileNameUnderlineToUpper, "model-filename-underline-to-upper", false, "The Model file name strategy: UnderlineToUpper")
	genCmd.PersistentFlags().BoolVar(&modelComment, "model-comment", true, "Generate Model comment")
	genCmd.PersistentFlags().BoolVar(&modelFieldComment, "model-field-comment", true, "Generate Model field comment")
	genCmd.PersistentFlags().BoolVar(&modelJSONTag, "model-json-tag", true, "Generate Model field JSON tag")
	genCmd.PersistentFlags().BoolVar(&modelJSONTagKeyDefault, "model-json-tag-key-default", true, "The Entity JSON Tag key strategy: default")
	genCmd.PersistentFlags().BoolVar(&modelJSONTagKeyFirstLetterUpper, "model-json-tag-key-first-letter-upper", false, "The Entity JSON Tag key strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&modelJSONTagKeyUnderlineToCamel, "model-json-tag-key-underline-to-camel", false, "The Entity JSON Tag key strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&modelJSONTagKeyUnderlineToUpper, "model-json-tag-key-underline-to-upper", false, "The Entity JSON Tag key strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVarP(&mapper, "mapper", "m", true, "Generate Mapper file")
	genCmd.PersistentFlags().StringVarP(&mapperPKG, "mapper-pkg", "2", "mapper", "The Mapper package")
	genCmd.PersistentFlags().BoolVar(&mapperNameDefault, "mapper-name-default", true, "The Mapper name strategy: default")
	genCmd.PersistentFlags().BoolVar(&mapperNameFirstLetterUpper, "mapper-name-first-letter-upper", false, "The Mapper name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&mapperNameUnderlineToCamel, "mapper-name-underline-to-camel", false, "The Mapper name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&mapperNameUnderlineToUpper, "mapper-name-underline-to-upper", false, "The Mapper name strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&mapperVarDefault, "mapper-var-default", true, "The Mapper var strategy: default")
	genCmd.PersistentFlags().BoolVar(&mapperVarFirstLetterUpper, "mapper-var-first-letter-upper", false, "The Mapper var strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&mapperVarUnderlineToCamel, "mapper-var-underline-to-camel", false, "The Mapper var strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&mapperVarUnderlineToUpper, "mapper-var-underline-to-upper", false, "The Mapper var strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&mapperFileNameDefault, "mapper-filename-default", true, "The Mapper FileName strategy: default")
	genCmd.PersistentFlags().BoolVar(&mapperFileNameFirstLetterUpper, "mapper-filename-first-letter-upper", false, "The Mapper FileName strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&mapperFileNameUnderlineToCamel, "mapper-filename-underline-to-camel", false, "The Mapper FileName strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&mapperFileNameUnderlineToUpper, "mapper-filename-underline-to-upper", false, "The Mapper FileName strategy: UnderlineToUpper")

	genCmd.PersistentFlags().StringVar(&mapperNamePrefix, "mapper-name-prefix", "", "The Mapper name prefix")
	genCmd.PersistentFlags().StringVar(&mapperNameSuffix, "mapper-name-suffix", "Mapper", "The Mapper name suffix")
	genCmd.PersistentFlags().StringVar(&mapperVarPrefix, "mapper-var-prefix", "", "The Mapper var prefix")
	genCmd.PersistentFlags().StringVar(&mapperVarSuffix, "mapper-var-suffix", "Mapper", "The Mapper var suffix")
	genCmd.PersistentFlags().BoolVar(&mapperComment, "mapper-comment", true, "Generate Mapper comment")
	genCmd.PersistentFlags().StringVar(&mapperBatis, "mapper-batis", "Batis", "The Mapper Batis name")

	genCmd.PersistentFlags().BoolVarP(&config, "config", "C", true, "Generate Config")
	genCmd.PersistentFlags().StringVarP(&configPKG, "config-pkg", "3", "config", "The Config package")

	genCmd.PersistentFlags().BoolVarP(&controller, "controller", "c", false, "Generate Controller file")
	genCmd.PersistentFlags().StringVarP(&controllerPKG, "controller-pkg", "4", "controller", "The Controller package")
	genCmd.PersistentFlags().BoolVar(&controllerNameDefault, "controller-name-default", false, "The Controller name strategy: default")
	genCmd.PersistentFlags().BoolVar(&controllerNameFirstLetterUpper, "controller-name-first-letter-upper", false, "The Controller name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&controllerNameUnderlineToCamel, "controller-name-underline-to-camel", true, "The Controller name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&controllerNameUnderlineToUpper, "controller-name-underline-to-upper", false, "The Controller name strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&controllerVarDefault, "controller-var-default", false, "The Controller var strategy: default")
	genCmd.PersistentFlags().BoolVar(&controllerVarFirstLetterUpper, "controller-var-first-letter-upper", false, "The Controller var strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&controllerVarUnderlineToCamel, "controller-var-underline-to-camel", false, "The Controller var strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&controllerVarUnderlineToUpper, "controller-var-underline-to-upper", true, "The Controller var strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&controllerFileNameDefault, "controller-filename-default", true, "The Controller FileName strategy: default")
	genCmd.PersistentFlags().BoolVar(&controllerFileNameFirstLetterUpper, "controller-filename-first-letter-upper", false, "The Controller FileName strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&controllerFileNameUnderlineToCamel, "controller-filename-underline-to-camel", false, "The Controller FileName strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&controllerFileNameUnderlineToUpper, "controller-filename-underline-to-upper", false, "The Controller FileName strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&controllerRouteDefault, "controller-route-default", true, "The Controller Route strategy: default")
	genCmd.PersistentFlags().BoolVar(&controllerRouteFirstLetterUpper, "controller-route-first-letter-upper", false, "The Controller Route strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&controllerRouteUnderlineToCamel, "controller-route-underline-to-camel", false, "The Controller Route strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&controllerRouteUnderlineToUpper, "controller-route-underline-to-upper", false, "The Controller Route strategy: UnderlineToUpper")

	genCmd.PersistentFlags().StringVar(&controllerNamePrefix, "controller-name-prefix", "", "The controller name prefix")
	genCmd.PersistentFlags().StringVar(&controllerNameSuffix, "controller-name-suffix", "controller", "The controller name suffix")
	genCmd.PersistentFlags().StringVar(&controllerRoutePrefix, "controller-route-prefix", "", "The controller route prefix")
	genCmd.PersistentFlags().StringVar(&controllerRouteSuffix, "controller-route-suffix", "", "The controller route suffix")
	genCmd.PersistentFlags().StringVar(&controllerVarPrefix, "controller-var-prefix", "", "The controller var prefix")
	genCmd.PersistentFlags().StringVar(&controllerVarSuffix, "controller-var-suffix", "controller", "The controller var suffix")
	genCmd.PersistentFlags().BoolVar(&controllerComment, "controller-comment", true, "Generate Controller comment")

	genCmd.PersistentFlags().BoolVarP(&service, "service", "s", false, "Generate Service file")
	genCmd.PersistentFlags().StringVarP(&servicePKG, "service-pkg", "5", "service", "The Service package")
	genCmd.PersistentFlags().BoolVar(&serviceNameDefault, "service-name-default", true, "The Service name strategy: default")
	genCmd.PersistentFlags().BoolVar(&serviceNameFirstLetterUpper, "service-name-first-letter-upper", false, "The Service name strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&serviceNameUnderlineToCamel, "service-name-underline-to-camel", false, "The Service name strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&serviceNameUnderlineToUpper, "service-name-underline-to-upper", false, "The Service name strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&serviceVarDefault, "service-var-default", true, "The Service var strategy: default")
	genCmd.PersistentFlags().BoolVar(&serviceVarFirstLetterUpper, "service-var-first-letter-upper", false, "The Service var strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&serviceVarUnderlineToCamel, "service-var-underline-to-camel", false, "The Service var strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&serviceVarUnderlineToUpper, "service-var-underline-to-upper", false, "The Service var strategy: UnderlineToUpper")

	genCmd.PersistentFlags().BoolVar(&serviceFileNameDefault, "service-filename-default", true, "The Service FileName strategy: default")
	genCmd.PersistentFlags().BoolVar(&serviceFileNameFirstLetterUpper, "service-filename-first-letter-upper", false, "The Service FileName strategy: FirstLetterUpper")
	genCmd.PersistentFlags().BoolVar(&serviceFileNameUnderlineToCamel, "service-filename-underline-to-camel", false, "The Service FileName strategy: UnderlineToCamel")
	genCmd.PersistentFlags().BoolVar(&serviceFileNameUnderlineToUpper, "service-filename-underline-to-upper", false, "The Service FileName strategy: UnderlineToUpper")

	genCmd.PersistentFlags().StringVar(&serviceNamePrefix, "service-name-prefix", "", "The Service name prefix")
	genCmd.PersistentFlags().StringVar(&serviceNameSuffix, "service-name-suffix", "Service", "The Service name suffix")
	genCmd.PersistentFlags().StringVar(&serviceVarPrefix, "service-var-prefix", "", "The Service var prefix")
	genCmd.PersistentFlags().StringVar(&serviceVarSuffix, "service-var-suffix", "Service", "The Service var suffix")
	genCmd.PersistentFlags().BoolVar(&serviceComment, "service-comment", true, "Generate Service comment")

	rootCmd.AddCommand(genCmd)
}

var (
	outputDir    = ""
	dsn          = ""
	module       = ""
	database     = ""
	includeTable = ""
	excludeTable = ""
	author       = ""
	verbose      = false

	model                            = true
	modelPKG                         = "model"
	modelTable2ModelDefault          = false
	modelTable2ModelFirstLetterUpper = false
	modelTable2ModelUnderlineToCamel = false
	modelTable2ModelUnderlineToUpper = true

	modelColumn2FieldDefault          = false
	modelColumn2FieldFirstLetterUpper = false
	modelColumn2FieldUnderlineToCamel = false
	modelColumn2FieldUnderlineToUpper = true

	modelFileNameDefault          = true
	modelFileNameFirstLetterUpper = false
	modelFileNameUnderlineToCamel = false
	modelFileNameUnderlineToUpper = false

	modelComment                    = true
	modelFieldComment               = true
	modelJSONTag                    = true
	modelJSONTagKeyDefault          = true
	modelJSONTagKeyFirstLetterUpper = false
	modelJSONTagKeyUnderlineToCamel = false
	modelJSONTagKeyUnderlineToUpper = false

	mapper    = true
	mapperPKG = "mapper"

	mapperNameDefault          = false
	mapperNameFirstLetterUpper = false
	mapperNameUnderlineToCamel = true
	mapperNameUnderlineToUpper = false

	mapperVarDefault          = false
	mapperVarFirstLetterUpper = false
	mapperVarUnderlineToCamel = false
	mapperVarUnderlineToUpper = true

	mapperFileNameDefault          = true
	mapperFileNameFirstLetterUpper = false
	mapperFileNameUnderlineToCamel = false
	mapperFileNameUnderlineToUpper = false

	mapperNamePrefix = ""
	mapperNameSuffix = "Mapper"
	mapperVarPrefix  = ""
	mapperVarSuffix  = "Mapper"
	mapperBatis      = "Batis"
	mapperComment    = true

	config    = true
	configPKG = "config"

	controller    = true
	controllerPKG = "controller"

	controllerNameDefault          = false
	controllerNameFirstLetterUpper = false
	controllerNameUnderlineToCamel = true
	controllerNameUnderlineToUpper = false

	controllerVarDefault          = false
	controllerVarFirstLetterUpper = false
	controllerVarUnderlineToCamel = false
	controllerVarUnderlineToUpper = true

	controllerRouteDefault          = true
	controllerRouteFirstLetterUpper = false
	controllerRouteUnderlineToCamel = false
	controllerRouteUnderlineToUpper = false

	controllerFileNameDefault          = true
	controllerFileNameFirstLetterUpper = false
	controllerFileNameUnderlineToCamel = false
	controllerFileNameUnderlineToUpper = false

	controllerNamePrefix  = ""
	controllerNameSuffix  = "Controller"
	controllerVarPrefix   = ""
	controllerVarSuffix   = "Controller"
	controllerRoutePrefix = "/"
	controllerRouteSuffix = ""
	controllerComment     = true

	service    = true
	servicePKG = "service"

	serviceNameDefault          = false
	serviceNameFirstLetterUpper = false
	serviceNameUnderlineToCamel = true
	serviceNameUnderlineToUpper = false

	serviceVarDefault          = false
	serviceVarFirstLetterUpper = false
	serviceVarUnderlineToCamel = false
	serviceVarUnderlineToUpper = true

	serviceFileNameDefault          = true
	serviceFileNameFirstLetterUpper = false
	serviceFileNameUnderlineToCamel = false
	serviceFileNameUnderlineToUpper = false

	serviceNamePrefix = ""
	serviceNameSuffix = "Service"
	serviceVarPrefix  = ""
	serviceVarSuffix  = "Service"
	serviceComment    = true
)

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
		CopyrightContent: "gobatis & flygo code generator written in Golang",
		Website:          true,
		WebsiteContent:   "https://github.com/billcoding/golang-code-generator",
	},
	Model: &ModelConfiguration{
		PKG:                   "model",
		TableToModelStrategy:  UnderlineToUpper,
		ColumnToFieldStrategy: UnderlineToUpper,
		FileNameStrategy:      Default,
		JSONTag:               true,
		JSONTagKeyStrategy:    Default,
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
		FileNameStrategy: Default,
		NamePrefix:       "",
		NameSuffix:       "Mapper",
		VarNamePrefix:    "",
		VarNameSuffix:    "Mapper",
		Comment:          true,
		Batis:            "Batis",
	},
	Config: &CfgConfiguration{
		PKG:  "config",
		Name: "config",
	},
	Predicate: &PredicateConfiguration{
		PKG:  "predicate",
		Name: "predicate",
	},
	Controller: &ControllerConfiguration{
		PKG:              "controller",
		NameStrategy:     UnderlineToCamel,
		VarNameStrategy:  UnderlineToUpper,
		RouteStrategy:    Default,
		FileNameStrategy: Default,
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
		NameStrategy:     UnderlineToCamel,
		VarNameStrategy:  UnderlineToUpper,
		FileNameStrategy: Default,
		NamePrefix:       "",
		NameSuffix:       "Service",
		VarNamePrefix:    "",
		VarNameSuffix:    "Service",
		Comment:          true,
	},
}

func setCFG() {
	if outputDir != "" {
		CFG.OutputDir = outputDir
	}
	if CFG.OutputDir == "" {
		exec, err := os.Getwd()
		if err != nil {
			panic(err)
		}
		CFG.OutputDir = exec
	}
	if module != "" {
		CFG.Module = module
	}
	if includeTable != "" {
		CFG.IncludeTables = strings.Split(includeTable, ",")
	} else if excludeTable != "" {
		CFG.ExcludeTables = strings.Split(excludeTable, ",")
	}

	if author != "" {
		CFG.Global.Author = author
	}

	{
		if modelPKG != "" {
			CFG.Model.PKG = modelPKG
		}

		CFG.Model.Comment = modelComment
		CFG.Model.FieldComment = modelFieldComment
		CFG.Model.JSONTag = modelJSONTag

		switch {
		case modelTable2ModelUnderlineToUpper:
			CFG.Model.TableToModelStrategy = UnderlineToUpper
		case modelTable2ModelUnderlineToCamel:
			CFG.Model.TableToModelStrategy = UnderlineToCamel
		case modelTable2ModelFirstLetterUpper:
			CFG.Model.TableToModelStrategy = FirstLetterUpper
		case modelTable2ModelDefault:
			CFG.Model.TableToModelStrategy = Default
		}

		switch {
		case modelColumn2FieldUnderlineToUpper:
			CFG.Model.ColumnToFieldStrategy = UnderlineToUpper
		case modelColumn2FieldUnderlineToCamel:
			CFG.Model.ColumnToFieldStrategy = UnderlineToCamel
		case modelColumn2FieldFirstLetterUpper:
			CFG.Model.ColumnToFieldStrategy = FirstLetterUpper
		case modelColumn2FieldDefault:
			CFG.Model.ColumnToFieldStrategy = Default
		}

		switch {
		case modelFileNameUnderlineToUpper:
			CFG.Model.FileNameStrategy = UnderlineToUpper
		case modelFileNameUnderlineToCamel:
			CFG.Model.FileNameStrategy = UnderlineToCamel
		case modelFileNameFirstLetterUpper:
			CFG.Model.FileNameStrategy = FirstLetterUpper
		case modelFileNameDefault:
			CFG.Model.FileNameStrategy = Default
		}

		switch {
		case modelJSONTagKeyUnderlineToUpper:
			CFG.Model.JSONTagKeyStrategy = UnderlineToUpper
		case modelJSONTagKeyUnderlineToCamel:
			CFG.Model.JSONTagKeyStrategy = UnderlineToCamel
		case modelJSONTagKeyFirstLetterUpper:
			CFG.Model.JSONTagKeyStrategy = FirstLetterUpper
		case modelJSONTagKeyDefault:
			CFG.Model.JSONTagKeyStrategy = Default
		}
	}

	{
		if mapperPKG != "" {
			CFG.Mapper.PKG = mapperPKG
		}
		CFG.Mapper.NamePrefix = mapperNamePrefix
		CFG.Mapper.NameSuffix = mapperNameSuffix
		CFG.Mapper.VarNamePrefix = mapperVarPrefix
		CFG.Mapper.VarNameSuffix = mapperVarSuffix
		CFG.Mapper.Comment = mapperComment
		CFG.Mapper.Batis = mapperBatis

		switch {
		case mapperNameUnderlineToUpper:
			CFG.Mapper.NameStrategy = UnderlineToUpper
		case mapperNameUnderlineToCamel:
			CFG.Mapper.NameStrategy = UnderlineToCamel
		case mapperNameFirstLetterUpper:
			CFG.Mapper.NameStrategy = FirstLetterUpper
		case mapperNameDefault:
			CFG.Mapper.NameStrategy = Default
		}

		switch {
		case mapperVarUnderlineToUpper:
			CFG.Mapper.VarNameStrategy = UnderlineToUpper
		case mapperVarUnderlineToCamel:
			CFG.Mapper.VarNameStrategy = UnderlineToCamel
		case mapperVarFirstLetterUpper:
			CFG.Mapper.VarNameStrategy = FirstLetterUpper
		case mapperVarDefault:
			CFG.Mapper.VarNameStrategy = Default
		}
		switch {
		case mapperFileNameUnderlineToUpper:
			CFG.Mapper.FileNameStrategy = UnderlineToUpper
		case mapperFileNameUnderlineToCamel:
			CFG.Mapper.FileNameStrategy = UnderlineToCamel
		case mapperFileNameFirstLetterUpper:
			CFG.Mapper.FileNameStrategy = FirstLetterUpper
		case mapperFileNameDefault:
			CFG.Mapper.FileNameStrategy = Default
		}
	}

	{
		if configPKG != "" {
			CFG.Config.PKG = configPKG
		}
	}

	{
		if controllerPKG != "" {
			CFG.Controller.PKG = controllerPKG
		}
		CFG.Controller.NamePrefix = controllerNamePrefix
		CFG.Controller.NameSuffix = controllerNameSuffix
		CFG.Controller.RoutePrefix = controllerRoutePrefix
		CFG.Controller.RouteSuffix = controllerRouteSuffix
		CFG.Controller.VarNamePrefix = controllerVarPrefix
		CFG.Controller.VarNameSuffix = controllerVarSuffix
		CFG.Controller.Comment = controllerComment

		switch {
		case controllerNameUnderlineToUpper:
			CFG.Controller.NameStrategy = UnderlineToUpper
		case controllerNameUnderlineToCamel:
			CFG.Controller.NameStrategy = UnderlineToCamel
		case controllerNameFirstLetterUpper:
			CFG.Controller.NameStrategy = FirstLetterUpper
		case controllerNameDefault:
			CFG.Controller.NameStrategy = Default
		}

		switch {
		case controllerVarUnderlineToUpper:
			CFG.Controller.VarNameStrategy = UnderlineToUpper
		case controllerVarUnderlineToCamel:
			CFG.Controller.VarNameStrategy = UnderlineToCamel
		case controllerVarFirstLetterUpper:
			CFG.Controller.VarNameStrategy = FirstLetterUpper
		case controllerVarDefault:
			CFG.Controller.VarNameStrategy = Default
		}

		switch {
		case controllerRouteUnderlineToUpper:
			CFG.Controller.RouteStrategy = UnderlineToUpper
		case controllerRouteUnderlineToCamel:
			CFG.Controller.RouteStrategy = UnderlineToCamel
		case controllerRouteFirstLetterUpper:
			CFG.Controller.RouteStrategy = FirstLetterUpper
		case controllerRouteDefault:
			CFG.Controller.RouteStrategy = Default
		}

		switch {
		case controllerFileNameUnderlineToUpper:
			CFG.Controller.FileNameStrategy = UnderlineToUpper
		case controllerFileNameUnderlineToCamel:
			CFG.Controller.FileNameStrategy = UnderlineToCamel
		case controllerFileNameFirstLetterUpper:
			CFG.Controller.FileNameStrategy = FirstLetterUpper
		case controllerFileNameDefault:
			CFG.Controller.FileNameStrategy = Default
		}
	}

	{
		if servicePKG != "" {
			CFG.Service.PKG = servicePKG
		}
		CFG.Service.NamePrefix = serviceNamePrefix
		CFG.Service.NameSuffix = serviceNameSuffix
		CFG.Service.VarNamePrefix = serviceVarPrefix
		CFG.Service.VarNameSuffix = serviceVarSuffix
		CFG.Service.Comment = serviceComment

		switch {
		case serviceNameUnderlineToUpper:
			CFG.Service.NameStrategy = UnderlineToUpper
		case serviceNameUnderlineToCamel:
			CFG.Service.NameStrategy = UnderlineToCamel
		case serviceNameFirstLetterUpper:
			CFG.Service.NameStrategy = FirstLetterUpper
		case serviceNameDefault:
			CFG.Service.NameStrategy = Default
		}

		switch {
		case serviceVarUnderlineToUpper:
			CFG.Service.VarNameStrategy = UnderlineToUpper
		case serviceVarUnderlineToCamel:
			CFG.Service.VarNameStrategy = UnderlineToCamel
		case serviceVarFirstLetterUpper:
			CFG.Service.VarNameStrategy = FirstLetterUpper
		case serviceVarDefault:
			CFG.Service.VarNameStrategy = Default
		}
		switch {
		case serviceFileNameUnderlineToUpper:
			CFG.Service.FileNameStrategy = UnderlineToUpper
		case serviceFileNameUnderlineToCamel:
			CFG.Service.FileNameStrategy = UnderlineToCamel
		case serviceFileNameFirstLetterUpper:
			CFG.Service.FileNameStrategy = FirstLetterUpper
		case serviceFileNameDefault:
			CFG.Service.FileNameStrategy = Default
		}
	}
}
