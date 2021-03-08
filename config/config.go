package config

type Configuration struct {
	Module        string
	OutputDir     string
	Verbose       bool
	IncludeTables []string
	ExcludeTables []string
	Global        *GlobalConfiguration
	Model         *ModelConfiguration
	Mapper        *MapperConfiguration
	Config        *CfgConfiguration
	Controller    *ControllerConfiguration
	Service       *ServiceConfiguration
}

type GlobalConfiguration struct {
	Author           string
	Date             bool
	DateLayout       string
	Copyright        bool
	CopyrightContent string
	Website          bool
	WebsiteContent   string
}

type ModelConfiguration struct {
	PKG                   string
	TableToModelStrategy  StrategyType
	ColumnToFieldStrategy StrategyType
	FileNameStrategy      StrategyType
	JSONTag               bool
	JSONTagStrategy       StrategyType
	FieldIdUpper          bool
	Comment               bool
	FieldComment          bool
	NamePrefix            string
	NameSuffix            string
}

type MapperConfiguration struct {
	PKG              string
	NameStrategy     StrategyType
	VarNameStrategy  StrategyType
	FileNameStrategy StrategyType
	NamePrefix       string
	NameSuffix       string
	VarNamePrefix    string
	VarNameSuffix    string
	Comment          bool
}

type CfgConfiguration struct {
	PKG     string
	Name    string
	Comment bool
}

type ControllerConfiguration struct {
	PKG              string
	NameStrategy     StrategyType
	VarNameStrategy  StrategyType
	RouteStrategy    StrategyType
	FileNameStrategy StrategyType
	NamePrefix       string
	NameSuffix       string
	RoutePrefix      string
	RouteSuffix      string
	VarNamePrefix    string
	VarNameSuffix    string
	Comment          bool
}

type ServiceConfiguration struct {
	PKG              string
	NameStrategy     StrategyType
	VarNameStrategy  StrategyType
	FileNameStrategy StrategyType
	NamePrefix       string
	NameSuffix       string
	VarNamePrefix    string
	VarNameSuffix    string
	Comment          bool
}
