// Hyprwave Assistant — updater, curated installer, and knowledge base TUI.
//
// Build: go build -o hyprwave-assistant .
// Data:  /usr/share/hyprwave/assistant/ (catalog.toml + kb/*.md)
//        override with HYPRWAVE_ASSISTANT_DATA or --data
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"

	tea "github.com/charmbracelet/bubbletea"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/cli"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/style"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/ui"
)

// version is overridden at link time: -ldflags "-X main.version=1.0.0"
var version = "0.2.2"

func main() {
	// Global flags work before subcommands: hyprwave-assistant --data DIR status
	fs := flag.NewFlagSet("hyprwave-assistant", flag.ContinueOnError)
	fs.SetOutput(os.Stderr)
	showVersion := fs.Bool("version", false, "print version and exit")
	dataDir := fs.String("data", "", "path to assistant data dir (catalog.toml + kb/)")
	// Parse only known global flags; leave subcommand args.
	args := os.Args[1:]
	var global []string
	var rest []string
	for i := 0; i < len(args); i++ {
		a := args[i]
		switch {
		case a == "-version" || a == "--version":
			global = append(global, "-version")
		case a == "-data" || a == "--data":
			global = append(global, "-data")
			if i+1 < len(args) {
				i++
				global = append(global, args[i])
			}
		case a == "-h" || a == "--help" || a == "help":
			// defer to CLI help if no other command; if alone, help
			if len(rest) == 0 && i == len(args)-1 {
				rest = []string{"help"}
			} else if a == "help" {
				rest = append(rest, a)
			} else {
				rest = append(rest, "help")
			}
		case len(a) > 0 && a[0] == '-' && (a == "-v"):
			global = append(global, "-version")
		default:
			rest = append(rest, args[i:]...)
			i = len(args)
		}
	}
	_ = fs.Parse(global)

	if *showVersion {
		fmt.Println("hyprwave-assistant", version)
		os.Exit(0)
	}

	dirs := dataDirs(*dataDir)
	cat, catErr := catalog.LoadFromDirs(dirs)
	store, kbErr := kb.LoadFromDirs(dirs)
	resolved := firstExisting(dirs)

	if len(rest) > 0 {
		if catErr != nil {
			cat = &catalog.Catalog{}
		}
		if kbErr != nil {
			store = &kb.Store{}
		}
		err := cli.Run(cli.Config{
			Runner:  system.ExecRunner{},
			Catalog: cat,
			KB:      store,
			Version: version,
		}, rest)
		if err != nil {
			fmt.Fprintln(os.Stderr, "hyprwave-assistant:", err)
			os.Exit(1)
		}
		return
	}

	// TUI path
	if catErr != nil {
		fmt.Fprintln(os.Stderr, "warning: catalog:", catErr)
		cat = &catalog.Catalog{}
	}
	if kbErr != nil {
		fmt.Fprintln(os.Stderr, "warning: knowledge base:", kbErr)
		store = &kb.Store{}
	}

	theme := style.InitFromEnv()

	m := ui.New(ui.Config{
		Runner:  system.ExecRunner{},
		Catalog: cat,
		KB:      store,
		DataDir: resolved,
		Version: version,
		Theme:   theme.Name,
	})

	p := tea.NewProgram(m, tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		fmt.Fprintln(os.Stderr, "hyprwave-assistant:", err)
		os.Exit(1)
	}
}

func dataDirs(flagDir string) []string {
	var dirs []string
	if flagDir != "" {
		dirs = append(dirs, flagDir)
	}
	if e := os.Getenv("HYPRWAVE_ASSISTANT_DATA"); e != "" {
		dirs = append(dirs, e)
	}
	dirs = append(dirs,
		"/usr/share/hyprwave/assistant",
		filepath.Join("build_files", "usr", "share", "hyprwave", "assistant"),
		filepath.Join("..", "..", "build_files", "usr", "share", "hyprwave", "assistant"),
		"testdata",
		filepath.Join("apps", "hyprwave-assistant", "testdata"),
	)
	if exe, err := os.Executable(); err == nil {
		dirs = append(dirs, filepath.Join(filepath.Dir(exe), "data"))
	}
	return dirs
}

func firstExisting(dirs []string) string {
	for _, d := range dirs {
		if st, err := os.Stat(d); err == nil && st.IsDir() {
			return d
		}
	}
	return "(none found — using empty catalog/KB)"
}
