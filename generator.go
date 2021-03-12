package main

import (
	. "github.com/billcoding/gobatis-flygo-code-generator/generator"
	. "github.com/billcoding/gobatis-flygo-code-generator/model"
)

func getModelGenerators(tableMap map[string]*Table) []Generator {
	egs := make([]Generator, 0)
	for _, v := range tableMap {
		eg := &ModelGenerator{
			C:     CFG,
			Table: v,
		}
		eg.Init()
		egs = append(egs, eg)
	}
	return egs
}

func getMapperGenerators(modelGenerators []Generator) []Generator {
	egs := make([]Generator, 0)
	for _, eg := range modelGenerators {
		mg := &MapperGenerator{
			C: CFG,
		}
		mg.Init(eg.(*ModelGenerator).Model)
		egs = append(egs, mg)
	}
	return egs
}

func getCfgGenerator() Generator {
	return &ConfigGenerator{
		C: CFG,
	}
}

func getPredicateGenerator() Generator {
	return &PredicateGenerator{
		C: CFG,
	}
}

func getControllerGenerators(modelGenerators []Generator) []Generator {
	cgs := make([]Generator, 0)
	for _, eg := range modelGenerators {
		cg := &ControllerGenerator{
			C: CFG,
		}
		cg.Init(eg.(*ModelGenerator).Model)
		cgs = append(cgs, cg)
	}
	return cgs
}

func getServiceGenerators(modelGenerators []Generator) []Generator {
	sgs := make([]Generator, 0)
	for _, eg := range modelGenerators {
		sg := &ServiceGenerator{
			C: CFG,
		}
		sg.Init(eg.(*ModelGenerator).Model)
		sgs = append(sgs, sg)
	}
	return sgs
}
