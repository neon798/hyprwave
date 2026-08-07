package system

import (
	"context"
	"fmt"
	"net"
	"os"
	"strings"
	"time"
)

// Preflight summarizes host readiness for update/install operations.
type Preflight struct {
	IsRoot           bool
	HasSudo          bool
	HasBootc         bool
	HasFlatpak       bool
	Online           bool
	OnlineDetail     string
	PrivilegeNote    string
	Warnings         []string
}

// CollectPreflight probes tools, privileges, and rough connectivity.
func CollectPreflight(r Runner) Preflight {
	p := Preflight{
		IsRoot: isRoot(),
	}
	if _, err := r.LookPath("bootc"); err == nil {
		p.HasBootc = true
	}
	if _, err := r.LookPath("flatpak"); err == nil {
		p.HasFlatpak = true
	}
	if _, err := r.LookPath("sudo"); err == nil {
		p.HasSudo = true
	}

	p.Online, p.OnlineDetail = probeOnline()

	switch {
	case p.IsRoot:
		p.PrivilegeNote = "running as root"
	case p.HasSudo:
		p.PrivilegeNote = "not root; will try sudo -n for bootc (may fail without NOPASSWD/polkit)"
	default:
		p.PrivilegeNote = "not root and no sudo in PATH — base upgrades will fail"
	}

	if !p.HasBootc {
		p.Warnings = append(p.Warnings, "bootc missing — base updates unavailable (not a bootc host?)")
	}
	if !p.HasFlatpak {
		p.Warnings = append(p.Warnings, "flatpak missing — app updates/installs unavailable")
	}
	if !p.Online {
		p.Warnings = append(p.Warnings, "network looks offline — remote updates/installs will fail: "+p.OnlineDetail)
	}
	if !p.IsRoot && !p.HasSudo {
		p.Warnings = append(p.Warnings, "no elevated privileges path for bootc upgrade")
	}
	return p
}

// CanMutateBase reports whether attempting bootc upgrade is plausible.
func (p Preflight) CanMutateBase() bool {
	return p.HasBootc && (p.IsRoot || p.HasSudo)
}

// CanMutateFlatpak reports whether flatpak mutations are plausible.
func (p Preflight) CanMutateFlatpak() bool {
	return p.HasFlatpak
}

// Summary is multi-line text for CLI/TUI.
func (p Preflight) Summary() string {
	var b strings.Builder
	b.WriteString(fmt.Sprintf("privileges: %s\n", p.PrivilegeNote))
	b.WriteString(fmt.Sprintf("bootc:      %s\n", yn(p.HasBootc)))
	b.WriteString(fmt.Sprintf("flatpak:    %s\n", yn(p.HasFlatpak)))
	b.WriteString(fmt.Sprintf("online:     %s (%s)\n", yn(p.Online), p.OnlineDetail))
	if len(p.Warnings) > 0 {
		b.WriteString("warnings:\n")
		for _, w := range p.Warnings {
			b.WriteString("  - " + w + "\n")
		}
	}
	return strings.TrimRight(b.String(), "\n")
}

func yn(v bool) string {
	if v {
		return "yes"
	}
	return "no"
}

// probeOnline does a short TCP dial to common public resolvers (no HTTP).
// Best-effort only; failures mean "maybe offline".
func probeOnline() (bool, string) {
	targets := []string{
		"1.1.1.1:443",
		"8.8.8.8:53",
		"flathub.org:443",
	}
	d := net.Dialer{Timeout: 2 * time.Second}
	var lastErr error
	for _, t := range targets {
		conn, err := d.DialContext(context.Background(), "tcp", t)
		if err == nil {
			_ = conn.Close()
			return true, "reached " + t
		}
		lastErr = err
	}
	if lastErr != nil {
		return false, lastErr.Error()
	}
	return false, "no targets"
}

// ClassifyError maps raw exec errors into clearer user messages.
func ClassifyError(err error, op string) error {
	if err == nil {
		return nil
	}
	msg := err.Error()
	lower := strings.ToLower(msg)

	switch {
	case strings.Contains(lower, "permission denied"),
		strings.Contains(lower, "operation not permitted"),
		strings.Contains(lower, "a password is required"),
		strings.Contains(lower, "sudo: a password is required"),
		strings.Contains(lower, "interactive authentication required"),
		strings.Contains(lower, "polkit"):
		return fmt.Errorf("%s needs elevated privileges (run as root, configure polkit/sudo, or use `sudo %s`)\n\noriginal: %w", op, op, err)

	case strings.Contains(lower, "network is unreachable"),
		strings.Contains(lower, "name or service not known"),
		strings.Contains(lower, "temporary failure in name resolution"),
		strings.Contains(lower, "could not resolve"),
		strings.Contains(lower, "no route to host"),
		strings.Contains(lower, "connection timed out"),
		strings.Contains(lower, "failed to connect"):
		return fmt.Errorf("%s failed: network/offline or DNS issue\n\noriginal: %w", op, err)

	case strings.Contains(lower, "not found") && strings.Contains(lower, "bootc"):
		return fmt.Errorf("bootc not available on this host\n\noriginal: %w", err)

	default:
		return fmt.Errorf("%s failed: %w", op, err)
	}
}

// RootOrSudoHint for CLI messages.
func RootOrSudoHint() string {
	if isRoot() {
		return ""
	}
	return "Hint: base image changes usually need `sudo`. This tool never reboots automatically."
}

// EnvHome returns HOME or empty.
func EnvHome() string {
	return os.Getenv("HOME")
}
