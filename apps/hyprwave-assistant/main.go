// Hyprwave Assistant — updater, curated installer, and knowledge base TUI.
//
// Build: go build -o hyprwave-assistant .
// Data:  /usr/share/hyprwave/assistant/ (catalog.toml + kb/*.md)
//        override with HYPRWAVE_ASSISTANT_DATA
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	tea "github.com/charmbracelet/bubbletea"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/ui"
)

// version is overridden at link time: -ldflags "-X main.version=1.0.0"
var version = "0.1.0"

func main() {
	showVersion := flag.Bool("version", false, "print version and exit")
	dataDir := flag.String("data", "", "path to assistant data dir (catalog.toml + kb/)")
	flag.Parse()

	if *showVersion {
		fmt.Println("hyprwave-assistant", version)
		os.Exit(0)
	}

	// Optional CLI subcommands (non-TUI fallbacks).
	args := flag.Args()
	if len(args) > 0 {
		if err := runCLI(args); err != nil {
			fmt.Fprintln(os.Stderr, "hyprwave-assistant:", err)
			os.Exit(1)
		}
		return
	}

	dirs := dataDirs(*dataDir)
	cat, catErr := catalog.LoadFromDirs(dirs)
	store, kbErr := kb.LoadFromDirs(dirs)

	resolved := firstExisting(dirs)

	if catErr != nil {
		fmt.Fprintln(os.Stderr, "warning: catalog:", catErr)
		cat = &catalog.Catalog{}
	}
	if kbErr != nil {
		fmt.Fprintln(os.Stderr, "warning: knowledge base:", kbErr)
		store = &kb.Store{}
	}

	m := ui.New(ui.Config{
		Runner:  system.ExecRunner{},
		Catalog: cat,
		KB:      store,
		DataDir: resolved,
		Version: version,
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
		// Dev / repo checkout: assets shipped for the image live here.
		filepath.Join("build_files", "usr", "share", "hyprwave", "assistant"),
		filepath.Join("..", "..", "build_files", "usr", "share", "hyprwave", "assistant"),
		// Local testdata next to module.
		"testdata",
		filepath.Join("apps", "hyprwave-assistant", "testdata"),
	)
	// Also try relative to executable.
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

func runCLI(args []string) error {
	r := system.ExecRunner{}
	switch args[0] {
	case "version":
		fmt.Println("hyprwave-assistant", version)
		return nil
	case "status":
		st := system.CollectStatus(r)
		fmt.Println("=== bootc ===")
		if st.BootcError != "" {
			fmt.Println(st.BootcError)
		} else {
			fmt.Println(st.BootcStatus)
		}
		if st.NeedsReboot {
			fmt.Println("\nWARNING: reboot may be required to apply staged changes.")
		}
		fmt.Println("\n=== flatpak ===")
		if st.FlatpakError != "" {
			fmt.Println(st.FlatpakError)
		} else {
			fmt.Println(st.FlatpakStatus)
		}
		return nil
	case "help", "-h", "--help":
		printHelp()
		return nil
	default:
		return fmt.Errorf("unknown command %q (try: status, version, help — or no args for TUI)", args[0])
	}
}

func printHelp() {
	fmt.Print(strings.TrimSpace(`
hyprwave-assistant — Hyprwave updater, installer & knowledge base

Usage:
  hyprwave-assistant              Launch TUI
  hyprwave-assistant status       Print bootc + flatpak status
  hyprwave-assistant version      Print version
  hyprwave-assistant --data DIR   Override data directory
  hyprwave-assistant --version

Environment:
  HYPRWAVE_ASSISTANT_DATA   Directory with catalog.toml and kb/

TUI keys:
  Tab / h l     Switch tabs
  1-4           Jump to Updater / Installer / KB / About
  r             Refresh status (Updater)
  b / f / a     Update base / Flatpaks / all (with confirm)
  Enter         Install selected / open article
  /             Filter or search
  q             Quit
`) + "\n")
}
