package system

import (
	"context"
	"fmt"
	"strings"
)

// RunCmd executes a planned Cmd, elevating with sudo -n when NeedsRoot and not root.
func RunCmd(ctx context.Context, r Runner, c Cmd) (string, error) {
	if _, err := r.LookPath(c.Name); err != nil {
		return "", fmt.Errorf("%s not available: %w", c.Name, err)
	}

	name, args := c.Name, c.Args
	if c.NeedsRoot && !isRoot() {
		if _, err := r.LookPath("sudo"); err != nil {
			return "", fmt.Errorf("%s requires root and sudo is not available", c.Name)
		}
		// Non-interactive sudo; fails clearly if password/polkit needed.
		args = append([]string{"-n", name}, args...)
		name = "sudo"
	}

	out, err := r.Run(ctx, name, args...)
	if err != nil {
		return out, ClassifyError(err, c.Shell())
	}
	return out, nil
}

// RunPlan executes commands in order; stops on first error.
// Returns combined output and whether any step requested a reboot hint.
func RunPlan(ctx context.Context, r Runner, cmds []Cmd) (output string, rebootHint bool, err error) {
	var b strings.Builder
	for i, c := range cmds {
		if i > 0 {
			b.WriteString("\n\n")
		}
		b.WriteString(fmt.Sprintf("=== %s ===\n", c.Shell()))
		out, e := RunCmd(ctx, r, c)
		if out != "" {
			b.WriteString(out)
		}
		if c.RebootHint {
			rebootHint = true
		}
		if e != nil {
			if out == "" {
				b.WriteString(e.Error())
			} else {
				b.WriteString("\n")
				b.WriteString(e.Error())
			}
			return b.String(), rebootHint, e
		}
	}
	if rebootHint {
		b.WriteString("\n\n⚠ Changes may be staged. Reboot yourself when ready — this tool never forces reboot.")
	}
	return b.String(), rebootHint, nil
}

// BootcUpgrade runs the upgrade plan via RunCmd (backward compatible).
func BootcUpgrade(ctx context.Context, r Runner) (string, error) {
	return RunCmd(ctx, r, BootcUpgradeCmd())
}

// FlatpakUpdate runs flatpak update -y.
func FlatpakUpdate(ctx context.Context, r Runner) (string, error) {
	return RunCmd(ctx, r, FlatpakUpdateCmd())
}

// FlatpakInstall installs from Flathub.
func FlatpakInstall(ctx context.Context, r Runner, appID string) (string, error) {
	c, err := PlanInstall(appID)
	if err != nil {
		return "", err
	}
	return RunCmd(ctx, r, c)
}
