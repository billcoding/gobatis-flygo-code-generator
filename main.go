package main

import (
	"flag"
	. "github.com/billcoding/gobatis-flygo-code-generator/generator"
)

func main() {
	flag.Parse()
	if *help {
		printUsage()
		return
	}

	if *version {
		printVersion()
		return
	}

	CFG.Verbose = *verbose

	if *module == "" {
		logger.Println("The module is required")
		return
	}

	if *dsn == "" {
		logger.Println("The DSN is required")
		return
	}

	if *database == "" {
		logger.Println("The Database name is required")
		return
	}

	initBatis()

	setCFG()

	tableList := tables(*database, CFG)
	columnList := columns(*database)
	tableMap := transformTables(tableList)
	columnMap := transformColumns(columnList)
	setTableColumns(tableMap, columnMap)
	generators := make([]Generator, 0)

	if !*model {
		if CFG.Verbose {
			logger.Println("Nothing do...")
		}
		return
	}

	modelGenerators := getModelGenerators(tableMap)
	generators = append(generators, modelGenerators...)

	if *mapper {
		mapperGenerators := getMapperGenerators(modelGenerators)
		generators = append(generators, mapperGenerators...)
		generators = append(generators, getPredicateGenerator())
	}

	if *config {
		generators = append(generators, getCfgGenerator())
	}

	if *controller {
		controllerGenerators := getControllerGenerators(modelGenerators)
		generators = append(generators, controllerGenerators...)
	}

	if *service {
		serviceGenerators := getServiceGenerators(modelGenerators)
		generators = append(generators, serviceGenerators...)
	}

	for _, generator := range generators {
		generator.Generate()
	}

}
