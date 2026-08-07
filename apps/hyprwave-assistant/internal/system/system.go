// Package system runs bootc and flatpak commands used by the Assistant.
package system

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"strings"
	"time"
)

// Runner executes external tools. Tests can substitute a fake.
type Runner interface {
	// Run executes name with args; captures combined stdout+stderr.
	Run(ctx context.Context, name string, args ...string) (string, error)
	// LookPath reports whether a binary is available.
	LookPath(name string) (string, error)
}

// ExecRunner is the production Runner using os/exec.
type ExecRunner struct{}

func (ExecRunner) LookPath(name string) (string, error) {
	return exec.LookPath(name)
}

func (ExecRunner) Run(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	var buf bytes.Buffer
	cmd.Stdout = &buf
	cmd.Stderr = &buf
	err := cmd.Run()
	out := strings.TrimSpace(buf.String())
	if err != nil {
		if out != "" {
			return out, fmt.Errorf("%s: %w\n%s", name, err, out)
		}
		return out, fmt.Errorf("%s: %w", name, err)
	}
	return out, nil
}

// DefaultTimeout for status checks.
const DefaultTimeout = 60 * time.Second

// LongTimeout for upgrades/installs.
const LongTimeout = 30 * time.Minute

// Status gathers bootc + flatpak availability and status text.
type Status struct {
	BootcAvailable   bool
	FlatpakAvailable bool
	BootcStatus      string
	BootcError       string
	FlatpakStatus    string
	FlatpakError     string
	NeedsReboot      bool
}

// CollectStatus runs bootc status and a flatpak summary.
func CollectStatus(r Runner) Status {
	var s Status
	if _, err := r.LookPath("bootc"); err == nil {
		s.BootcAvailable = true
		ctx, cancel := context.WithTimeout(context.Background(), DefaultTimeout)
		defer cancel()
		out, err := r.Run(ctx, "bootc", "status")
		if err != nil {
			s.BootcError = err.Error()
		} else {
			s.BootcStatus = out
			s.NeedsReboot = DetectNeedsReboot(out)
		}
	} else {
		s.BootcError = "bootc not found (not an atomic/bootc host?)"
	}

	if _, err := r.LookPath("flatpak"); err == nil {
		s.FlatpakAvailable = true
		ctx, cancel := context.WithTimeout(context.Background(), DefaultTimeout)
		defer cancel()
		// List remotes + brief update check summary without applying.
		out, err := r.Run(ctx, "flatpak", "list", "--columns=application,version,origin")
		if err != nil {
			s.FlatpakError = err.Error()
		} else {
			lines := strings.Split(out, "\n")
			n := len(lines)
			if out == "" {
				n = 0
			}
			s.FlatpakStatus = fmt.Sprintf("%d installed Flatpak(s)\n\n%s", n, truncate(out, 40))
		}
	} else {
		s.FlatpakError = "flatpak not found"
	}
	return s
}

// DetectNeedsReboot scans bootc status text for staged/pending deployment hints.
func DetectNeedsReboot(status string) bool {
	lower := strings.ToLower(status)
	// Negative forms first (avoid "staged: none" false positives).
	if strings.Contains(lower, "staged: none") || strings.Contains(lower, "staged: no") {
		// still check other strong signals below
	} else if strings.Contains(lower, "staged") {
		return true
	}
	needles := []string{
		"pending deployment",
		"reboot required",
		"reboot is required",
		"reboot to apply",
		"next boot",
		"uncommitted",
	}
	for _, n := range needles {
		if strings.Contains(lower, n) {
			return true
		}
	}
	return false
}

func truncate(s string, maxLines int) string {
	lines := strings.Split(s, "\n")
	if len(lines) <= maxLines {
		return s
	}
	return strings.Join(lines[:maxLines], "\n") + fmt.Sprintf("\n… (%d more lines)", len(lines)-maxLines)
}

// BootcUpgrade runs `bootc upgrade` (may need root). Prefer `bootc upgrade` over deprecated `bootc update`.
func BootcUpgrade(ctx context.Context, r Runner) (string, error) {
	if _, err := r.LookPath("bootc"); err != nil {
		return "", fmt.Errorf("bootc not available: %w", err)
	}
	// Try without sudo first; many systems need elevated privileges.
	out, err := r.Run(ctx, "bootc", "upgrade")
	if err != nil && !isRoot() {
		// Retry via sudo -n if available (non-interactive).
		if _, e := r.LookPath("sudo"); e == nil {
			return r.Run(ctx, "sudo", "-n", "bootc", "upgrade")
		}
	}
	return out, err
}

// FlatpakUpdate runs `flatpak update -y`.
func FlatpakUpdate(ctx context.Context, r Runner) (string, error) {
	if _, err := r.LookPath("flatpak"); err != nil {
		return "", fmt.Errorf("flatpak not available: %w", err)
	}
	return r.Run(ctx, "flatpak", "update", "-y")
}

// FlatpakInstall installs a Flathub app id with -y.
func FlatpakInstall(ctx context.Context, r Runner, appID string) (string, error) {
	if _, err := r.LookPath("flatpak"); err != nil {
		return "", fmt.Errorf("flatpak not available: %w", err)
	}
	if strings.TrimSpace(appID) == "" {
		return "", fmt.Errorf("empty flatpak id")
	}
	// Ensure flathub exists is best-effort; install will fail clearly otherwise.
	return r.Run(ctx, "flatpak", "install", "-y", "flathub", appID)
}

// LayerNote explains that layering is not automated from the TUI yet.
func LayerNote(packages []string) string {
	return fmt.Sprintf(
		"Layered packages require a bootc/rpm-ostree layer and reboot.\n"+
			"This Assistant does not auto-layer yet.\n\n"+
			"Suggested (review before running):\n"+
			"  sudo bootc usroverlay   # or your image rebuild workflow\n"+
			"  # packages: %s\n\n"+
			"Prefer Flatpaks when possible to keep the base immutable.",
		strings.Join(packages, ", "),
	)
}

func isRoot() bool {
	return os.Geteuid() == 0
}

// Which reports tool availability as a short string.
func Which(r Runner, names ...string) map[string]bool {
	m := make(map[string]bool, len(names))
	for _, n := range names {
		_, err := r.LookPath(n)
		m[n] = err == nil
	}
	return m
}
