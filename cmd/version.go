package cmd

import (
	"fmt"
	"github.com/spf13/cobra"
	"os"
	"runtime"
)

var versionCmd = &cobra.Command{
	Use:     "version",
	Aliases: []string{"v", "ver"},
	Short:   "Print the version",
	Long: `Print the version of golang-code-generator.
Simply type fly help version for full details.`,
	Example: `golang-code-generator version [-a]`,
	Run: func(cmd *cobra.Command, args []string) {
		PrintVersion(goVersionFlag)
	},
}

var goVersionFlag = false

func init() {
	versionCmd.PersistentFlags().BoolVarP(&goVersionFlag, "all", "a", false, "print Go SDK version")
	rootCmd.AddCommand(versionCmd)
}

const version = "1.0"

func PrintVersion(goVersion bool) {
	fmt.Fprintln(os.Stdout, version)
	if goVersion {
		fmt.Fprintln(os.Stdout, runtime.Version())
	}
}
