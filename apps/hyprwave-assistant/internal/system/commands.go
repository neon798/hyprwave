// Command builders for bootc/flatpak — used by CLI dry-run and the TUI.
package system

import (
	"fmt"
	"strings"
)

// Target selects what an update operation affects.
type Target string

const (
	TargetBase    Target = "base"
	TargetFlatpak Target = "flatpak"
	TargetAll     Target = "all"
)

// Cmd is a planned external command (argv).
type Cmd struct {
	Name string
	Args []string
	// NeedsRoot is advisory: true if typically requires elevated privileges.
	NeedsRoot bool
	// RebootHint is true if success may require a user-initiated reboot (never forced).
	RebootHint bool
	// Description is human-readable.
	Description string
}

// Argv returns name + args as a single slice.
func (c Cmd) Argv() []string {
	out := make([]string, 0, 1+len(c.Args))
	out = append(out, c.Name)
	out = append(out, c.Args...)
	return out
}

// Shell returns a shell-quoted-ish display string (for dry-run).
func (c Cmd) Shell() string {
	parts := []string{c.Name}
	for _, a := range c.Args {
		if strings.ContainsAny(a, " \t\"'") {
			parts = append(parts, fmt.Sprintf("%q", a))
		} else {
			parts = append(parts, a)
		}
	}
	s := strings.Join(parts, " ")
	if c.NeedsRoot {
		s = "sudo " + s
	}
	return s
}

// BootcStatusCmd is a non-mutating status check.
func BootcStatusCmd() Cmd {
	return Cmd{
		Name:        "bootc",
		Args:        []string{"status"},
		Description: "Show booted and staged bootc deployments",
	}
}

// BootcUpgradeCmd stages a base image upgrade (does not reboot).
func BootcUpgradeCmd() Cmd {
	return Cmd{
		Name:        "bootc",
		Args:        []string{"upgrade"},
		NeedsRoot:   true,
		RebootHint:  true,
		Description: "Stage base image upgrade (reboot separately to apply)",
	}
}

// FlatpakListCmd lists installed flatpaks.
func FlatpakListCmd() Cmd {
	return Cmd{
		Name:        "flatpak",
		Args:        []string{"list", "--columns=application,version,origin"},
		Description: "List installed Flatpaks",
	}
}

// FlatpakRemoteLsUpdatesCmd checks for available flatpak updates without applying.
func FlatpakRemoteLsUpdatesCmd() Cmd {
	return Cmd{
		Name:        "flatpak",
		Args:        []string{"remote-ls", "--updates"},
		Description: "List available Flatpak updates (check only)",
	}
}

// FlatpakUpdateCmd applies flatpak updates non-interactively.
func FlatpakUpdateCmd() Cmd {
	return Cmd{
		Name:        "flatpak",
		Args:        []string{"update", "-y"},
		Description: "Update all Flatpaks",
	}
}

// FlatpakInstallCmd installs one Flathub app id.
func FlatpakInstallCmd(appID string) Cmd {
	return Cmd{
		Name:        "flatpak",
		Args:        []string{"install", "-y", "flathub", appID},
		Description: "Install Flatpak from Flathub: " + appID,
	}
}

// PlanUpdate returns the ordered commands for a target.
// checkOnly: status/remote-ls only (no mutations).
// dryRun is handled by the caller (print Plan, do not execute).
func PlanUpdate(target Target, checkOnly bool) ([]Cmd, error) {
	switch target {
	case TargetBase:
		if checkOnly {
			return []Cmd{BootcStatusCmd()}, nil
		}
		return []Cmd{BootcUpgradeCmd()}, nil
	case TargetFlatpak:
		if checkOnly {
			return []Cmd{FlatpakRemoteLsUpdatesCmd()}, nil
		}
		return []Cmd{FlatpakUpdateCmd()}, nil
	case TargetAll:
		if checkOnly {
			return []Cmd{FlatpakRemoteLsUpdatesCmd(), BootcStatusCmd()}, nil
		}
		// Flatpaks first (no reboot), then base (reboot hint).
		return []Cmd{FlatpakUpdateCmd(), BootcUpgradeCmd()}, nil
	default:
		return nil, fmt.Errorf("unknown update target %q (use base|flatpak|all)", target)
	}
}

// PlanInstall returns commands for a flatpak app id (or empty for layer notes).
func PlanInstall(appID string) (Cmd, error) {
	appID = strings.TrimSpace(appID)
	if appID == "" {
		return Cmd{}, fmt.Errorf("empty flatpak application id")
	}
	return FlatpakInstallCmd(appID), nil
}

// FormatPlan prints a command plan (used for dry-run and confirmations).
func FormatPlan(cmds []Cmd) string {
	return FormatPlanBanner(cmds, "Command plan:")
}

// FormatDryRun prints a dry-run banner plan.
func FormatDryRun(cmds []Cmd) string {
	return FormatPlanBanner(cmds, "Dry-run plan (nothing will be executed):")
}

// FormatPlanBanner formats cmds with a custom header line.
func FormatPlanBanner(cmds []Cmd, header string) string {
	var b strings.Builder
	b.WriteString(header + "\n")
	for i, c := range cmds {
		b.WriteString(fmt.Sprintf("  %d. %s\n", i+1, c.Shell()))
		if c.Description != "" {
			b.WriteString(fmt.Sprintf("     # %s\n", c.Description))
		}
		if c.RebootHint {
			b.WriteString("     # NOTE: may stage changes; reboot is never forced by this tool\n")
		}
	}
	return b.String()
}
