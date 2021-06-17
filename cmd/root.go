package cmd

import (
	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "golang-code-generator",
	Short: "A Go code generator",
	Long: `It is a command line tool for gobatis & flygo in Golang.
It contains: Model/Mapper/XML/Service/Controller.
The GitHub site at https://github.com/billcoding/golang-code-generator`,
	Run: func(cmd *cobra.Command, args []string) {
		if versionFlag {
			PrintVersion(false)
		}
	},
}

var versionFlag bool

// Execute executes the root command.
func Execute() error {
	rootCmd.PersistentFlags().BoolVarP(&versionFlag, "version", "v", false, "version")
	return rootCmd.Execute()
}
