// Package cli implements non-interactive hyprwave-assistant subcommands.
package cli

import (
	"context"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
)

// Config for CLI execution.
type Config struct {
	Stdout  io.Writer
	Stderr  io.Writer
	Runner  system.Runner
	Catalog *catalog.Catalog
	KB      *kb.Store
	Version string
	// ConfirmYes skips interactive yes/no (for scripted installs/updates).
	// Destructive ops still refuse unless DryRun, Check, or Yes is set.
	Yes bool
}

func (c *Config) out() io.Writer {
	if c.Stdout != nil {
		return c.Stdout
	}
	return os.Stdout
}

func (c *Config) err() io.Writer {
	if c.Stderr != nil {
		return c.Stderr
	}
	return os.Stderr
}

func (c *Config) runner() system.Runner {
	if c.Runner != nil {
		return c.Runner
	}
	return system.ExecRunner{}
}

// Run dispatches subcommands. args[0] is the command name.
func Run(cfg Config, args []string) error {
	if len(args) == 0 {
		return fmt.Errorf("no command")
	}
	switch args[0] {
	case "help", "-h", "--help":
		PrintHelp(cfg.out(), cfg.Version)
		return nil
	case "version":
		PrintVersion(cfg.out(), cfg.Version)
		return nil
	case "status":
		return runStatus(cfg, args[1:])
	case "update":
		return runUpdate(cfg, args[1:])
	case "install":
		return runInstall(cfg, args[1:])
	case "kb":
		return runKB(cfg, args[1:])
	case "list":
		return runList(cfg, args[1:])
	default:
		return fmt.Errorf("unknown command %q (try: help)", args[0])
	}
}

// PrintVersion writes version + short product identity (no public-GHCR claims).
func PrintVersion(w io.Writer, version string) {
	if version == "" {
		version = "0.2.2"
	}
	fmt.Fprintln(w, "hyprwave-assistant", version)
	fmt.Fprintln(w, "Hyprwave system companion for Hyprland + COSMIC images.")
	fmt.Fprintln(w, "Hyprland: Super+Shift+A · menu entry · CLI. Never auto-reboots.")
	fmt.Fprintln(w, "GHCR packages may be private; localhost image tags are valid for local builds.")
}

// PrintHelp writes usage.
func PrintHelp(w io.Writer, version string) {
	fmt.Fprintf(w, `hyprwave-assistant %s — updater, installer & knowledge base (Hyprland + COSMIC)

Usage:
  hyprwave-assistant                      Launch TUI
  hyprwave-assistant status [--check]     bootc + flatpak status (+ preflight)
  hyprwave-assistant update [flags]       Update base and/or Flatpaks
  hyprwave-assistant install <id> [flags] Install catalog id or flatpak id
  hyprwave-assistant list [--source X]    List curated catalog
  hyprwave-assistant kb [query]           Search / print knowledge base
  hyprwave-assistant version
  hyprwave-assistant help

Update flags:
  --base          Base image only (bootc upgrade)
  --flatpak       Flatpaks only
  --all           Flatpaks then base (default)
  --check         Non-mutating check (status / remote-ls --updates)
  --dry-run       Print plan only; never execute
  --yes           First confirmation for mutating ops (scripted)
  --confirm       Second confirmation (required with --yes for all mutations)

Install flags:
  --dry-run       Print flatpak install plan
  --yes --confirm Required together for real install (double-confirm)

Global:
  --data DIR / HYPRWAVE_ASSISTANT_DATA   Data directory

Notes:
  • This tool never reboots the system.
  • Destructive paths need dry-run available + double confirm (--yes and --confirm).
  • Base upgrades need root/sudo/polkit; failures are reported clearly.
  • Prefer Flatpak for apps; layer catalog entries print instructions only.
  • Offline: KB + catalog still work; updater blocks remote ops clearly.
  • GHCR may be private (401/403) — localhost tags are valid; see: kb ghcr
  • Hyprland keybind: Super+Shift+A (Ghostty). Not Wofi/swaybg — those are not the stack.
`, version)
}

func runStatus(cfg Config, args []string) error {
	check := hasFlag(args, "--check")
	r := cfg.runner()
	st := system.CollectStatus(r)

	fmt.Fprintln(cfg.out(), "=== preflight ===")
	fmt.Fprintln(cfg.out(), st.Preflight.Summary())
	fmt.Fprintln(cfg.out())
	fmt.Fprintln(cfg.out(), "=== bootc ===")
	if st.BootcError != "" {
		fmt.Fprintln(cfg.out(), st.BootcError)
	} else {
		fmt.Fprintln(cfg.out(), st.BootcStatus)
	}
	if st.ImageRef != "" {
		fmt.Fprintln(cfg.out(), "\nimage ref:", st.ImageRef)
	}
	if st.ImageNote != "" {
		fmt.Fprintln(cfg.out(), "note:", st.ImageNote)
	}
	if st.NeedsReboot {
		fmt.Fprintln(cfg.out(), "\nWARNING: staged/pending changes — reboot yourself when ready (never forced).")
	}
	fmt.Fprintln(cfg.out(), "\n=== flatpak ===")
	if st.FlatpakError != "" {
		fmt.Fprintln(cfg.out(), st.FlatpakError)
	} else {
		fmt.Fprintln(cfg.out(), st.FlatpakStatus)
	}

	if check && st.FlatpakAvailable {
		fmt.Fprintln(cfg.out(), "\n=== flatpak updates available (--check) ===")
		ctx, cancel := context.WithTimeout(context.Background(), system.CheckTimeout)
		defer cancel()
		out, err := system.RunCmd(ctx, r, system.FlatpakRemoteLsUpdatesCmd())
		if err != nil {
			fmt.Fprintln(cfg.err(), err)
		} else if strings.TrimSpace(out) == "" {
			fmt.Fprintln(cfg.out(), "(none reported)")
		} else {
			fmt.Fprintln(cfg.out(), out)
		}
	}
	if h := system.RootOrSudoHint(); h != "" {
		fmt.Fprintln(cfg.out(), "\n"+h)
	}
	return nil
}

func runUpdate(cfg Config, args []string) error {
	dry := hasFlag(args, "--dry-run")
	check := hasFlag(args, "--check")
	yes := cfg.Yes || hasFlag(args, "--yes")
	confirm := hasFlag(args, "--confirm")

	target := system.TargetAll
	switch {
	case hasFlag(args, "--base"):
		target = system.TargetBase
	case hasFlag(args, "--flatpak"):
		target = system.TargetFlatpak
	case hasFlag(args, "--all"):
		target = system.TargetAll
	}

	cmds, err := system.PlanUpdate(target, check)
	if err != nil {
		return err
	}

	if dry || check {
		// check still executes read-only commands unless also dry-run
		if dry {
			fmt.Fprint(cfg.out(), system.FormatDryRun(cmds))
			return nil
		}
		// execute check plan
		ctx, cancel := context.WithTimeout(context.Background(), system.CheckTimeout)
		defer cancel()
		out, _, err := system.RunPlan(ctx, cfg.runner(), cmds)
		fmt.Fprintln(cfg.out(), out)
		return err
	}

	// Mutating path
	pf := system.CollectPreflight(cfg.runner())
	fmt.Fprintln(cfg.out(), pf.Summary())
	if ban := pf.OfflineBanner(); ban != "" {
		fmt.Fprintln(cfg.out(), ban)
		return fmt.Errorf("refusing remote update while offline (KB/catalog still work; try again online)")
	}
	if (target == system.TargetBase || target == system.TargetAll) && !pf.CanMutateBase() {
		return fmt.Errorf("cannot update base: bootc/privileges unavailable")
	}
	if (target == system.TargetFlatpak || target == system.TargetAll) && !pf.CanMutateFlatpak() {
		return fmt.Errorf("cannot update flatpak: flatpak unavailable")
	}
	if err := requireDoubleConfirm(yes, confirm, cmds); err != nil {
		return err
	}

	fmt.Fprintln(cfg.out(), "Executing (double-confirmed):")
	fmt.Fprint(cfg.out(), system.FormatPlan(cmds))
	ctx, cancel := context.WithTimeout(context.Background(), system.LongTimeout)
	defer cancel()
	out, reboot, err := system.RunPlan(ctx, cfg.runner(), cmds)
	fmt.Fprintln(cfg.out(), out)
	if reboot {
		fmt.Fprintln(cfg.out(), "Reminder: reboot manually if a new deployment was staged.")
	}
	return err
}

// requireDoubleConfirm enforces --yes and --confirm for destructive CLI ops.
func requireDoubleConfirm(yes, confirm bool, cmds []system.Cmd) error {
	if yes && confirm {
		return nil
	}
	plan := system.FormatPlan(cmds)
	switch {
	case !yes && !confirm:
		return fmt.Errorf("refusing mutation without double-confirm: pass --yes --confirm (or --dry-run)\n%s", plan)
	case !yes:
		return fmt.Errorf("refusing mutation: missing --yes (double-confirm requires --yes --confirm)\n%s", plan)
	default:
		return fmt.Errorf("refusing mutation: missing --confirm (second confirmation after --yes)\n%s", plan)
	}
}

func runInstall(cfg Config, args []string) error {
	dry := hasFlag(args, "--dry-run")
	yes := cfg.Yes || hasFlag(args, "--yes")
	confirm := hasFlag(args, "--confirm")
	pos := positional(args)
	if len(pos) < 1 {
		return fmt.Errorf("usage: hyprwave-assistant install <catalog-id|flatpak-id> [--dry-run|--yes --confirm]")
	}
	id := pos[0]

	// Resolve catalog id if possible.
	var appID string
	var layerPkgs []string
	var name string
	if cfg.Catalog != nil {
		if it := cfg.Catalog.Find(id); it != nil {
			name = it.Name
			if it.Source == catalog.SourceLayer {
				layerPkgs = it.Packages
			} else {
				appID = it.Flatpak
			}
		}
	}
	if appID == "" && len(layerPkgs) == 0 {
		// treat as raw flatpak id
		if strings.Contains(id, ".") {
			appID = id
			name = id
		} else if cfg.Catalog != nil {
			return fmt.Errorf("unknown catalog id %q (try: hyprwave-assistant list)", id)
		} else {
			return fmt.Errorf("no catalog loaded and %q is not a flatpak id", id)
		}
	}

	if len(layerPkgs) > 0 {
		fmt.Fprintln(cfg.out(), "Catalog entry is layered (not auto-installed):", name)
		fmt.Fprintln(cfg.out(), system.LayerNote(layerPkgs))
		return nil
	}

	cmd, err := system.PlanInstall(appID)
	if err != nil {
		return err
	}
	if dry {
		fmt.Fprint(cfg.out(), system.FormatDryRun([]system.Cmd{cmd}))
		return nil
	}
	if err := requireDoubleConfirm(yes, confirm, []system.Cmd{cmd}); err != nil {
		return err
	}

	pf := system.CollectPreflight(cfg.runner())
	if ban := pf.OfflineBanner(); ban != "" {
		fmt.Fprintln(cfg.out(), ban)
		return fmt.Errorf("refusing install while offline")
	}
	if !pf.CanMutateFlatpak() {
		return fmt.Errorf("flatpak not available")
	}

	ctx, cancel := context.WithTimeout(context.Background(), system.LongTimeout)
	defer cancel()
	out, err := system.RunCmd(ctx, cfg.runner(), cmd)
	fmt.Fprintln(cfg.out(), out)
	return err
}

func runKB(cfg Config, args []string) error {
	if cfg.KB == nil || len(cfg.KB.Articles) == 0 {
		return fmt.Errorf("knowledge base empty or not loaded")
	}
	pos := positional(args)
	query := strings.Join(pos, " ")
	if query == "" {
		for _, a := range cfg.KB.Articles {
			fmt.Fprintf(cfg.out(), "%-16s  %s\n", a.ID, a.Title)
		}
		return nil
	}
	// Exact id
	if a := cfg.KB.Get(query); a != nil {
		fmt.Fprintln(cfg.out(), a.Body)
		return nil
	}
	hits := cfg.KB.Search(query)
	if len(hits) == 0 {
		return fmt.Errorf("no articles match %q", query)
	}
	// If single hit or query matches title closely, print body
	if len(hits) == 1 {
		fmt.Fprintln(cfg.out(), hits[0].Body)
		return nil
	}
	fmt.Fprintf(cfg.out(), "Matches for %q:\n", query)
	for _, a := range hits {
		fmt.Fprintf(cfg.out(), "  %-16s  %s\n", a.ID, a.Title)
	}
	fmt.Fprintln(cfg.out(), "\nShow one: hyprwave-assistant kb <id>")
	return nil
}

func runList(cfg Config, args []string) error {
	if cfg.Catalog == nil {
		return fmt.Errorf("catalog not loaded")
	}
	srcFilter := ""
	for i, a := range args {
		if a == "--source" && i+1 < len(args) {
			srcFilter = args[i+1]
		}
		if strings.HasPrefix(a, "--source=") {
			srcFilter = strings.TrimPrefix(a, "--source=")
		}
	}
	for _, row := range cfg.Catalog.FlatList() {
		it := row.Item
		if srcFilter != "" && string(it.Source) != srcFilter {
			continue
		}
		fmt.Fprintf(cfg.out(), "%-14s  %-28s  %-8s  %s\n", it.ID, it.Name, it.Source, it.InstallLabel())
	}
	return nil
}

func hasFlag(args []string, name string) bool {
	for _, a := range args {
		if a == name {
			return true
		}
	}
	return false
}

func positional(args []string) []string {
	var out []string
	skip := false
	for i, a := range args {
		if skip {
			skip = false
			continue
		}
		if a == "--source" {
			skip = true
			continue
		}
		if strings.HasPrefix(a, "-") {
			continue
		}
		_ = i
		out = append(out, a)
	}
	return out
}
