package style

import (
	"os"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/lipgloss"
)

// ThemeInfo is best-effort active theme metadata.
type ThemeInfo struct {
	Name   string
	Source string // env|file|default
}

// DetectTheme reads HYPRWAVE_THEME, then ~/.config/hyprwave/theme (file or symlink).
func DetectTheme() ThemeInfo {
	if v := strings.TrimSpace(os.Getenv("HYPRWAVE_THEME")); v != "" {
		return ThemeInfo{Name: v, Source: "env"}
	}
	home, err := os.UserHomeDir()
	if err != nil || home == "" {
		return ThemeInfo{Name: "synthwave", Source: "default"}
	}
	p := filepath.Join(home, ".config", "hyprwave", "theme")
	// Symlink → basename of target often is the theme name.
	if target, err := os.Readlink(p); err == nil {
		base := filepath.Base(strings.TrimRight(target, "/"))
		if base != "" && base != "." && base != "theme" {
			return ThemeInfo{Name: base, Source: "symlink"}
		}
	}
	// Regular file with theme name on first line.
	if data, err := os.ReadFile(p); err == nil {
		line := strings.TrimSpace(strings.SplitN(string(data), "\n", 2)[0])
		line = strings.TrimSpace(strings.TrimPrefix(line, "name="))
		if line != "" {
			return ThemeInfo{Name: line, Source: "file"}
		}
	}
	return ThemeInfo{Name: "synthwave", Source: "default"}
}

// ApplyAccent tweaks chrome colors for a few known theme names (best-effort).
// Unknown themes keep classic synthwave pink/cyan.
func ApplyAccent(name string) {
	n := strings.ToLower(strings.TrimSpace(name))
	switch {
	case strings.Contains(n, "verdant"), strings.Contains(n, "forest"), strings.Contains(n, "haven"):
		Pink = lipgloss.Color("#3dff9a")
		Cyan = lipgloss.Color("#7CFFB2")
		Purple = lipgloss.Color("#2db36b")
	case strings.Contains(n, "fjord"), strings.Contains(n, "lunar"), strings.Contains(n, "ice"):
		Pink = lipgloss.Color("#7ec8ff")
		Cyan = lipgloss.Color("#a8e0ff")
		Purple = lipgloss.Color("#5b8def")
	case strings.Contains(n, "arcade"), strings.Contains(n, "retro"), strings.Contains(n, "glitch"):
		Pink = lipgloss.Color("#ff3d7f")
		Cyan = lipgloss.Color("#39ff14")
		Purple = lipgloss.Color("#bf5fff")
	case strings.Contains(n, "harvest"), strings.Contains(n, "cozy"), strings.Contains(n, "haze"):
		Pink = lipgloss.Color("#ff9f43")
		Cyan = lipgloss.Color("#f8d56b")
		Purple = lipgloss.Color("#c77d4e")
	default:
		// classic synthwave — already set as package defaults
		return
	}
	rebuildStyles()
}

func rebuildStyles() {
	TabActive = lipgloss.NewStyle().Foreground(Bg).Background(Pink).Bold(true).Padding(0, 2)
	TabIdle = lipgloss.NewStyle().Foreground(Purple).Padding(0, 2)
	Title = lipgloss.NewStyle().Foreground(Cyan).Bold(true)
	Selected = lipgloss.NewStyle().Foreground(Bg).Background(Cyan).Bold(true)
	Highlight = lipgloss.NewStyle().Foreground(Pink).Bold(true)
	Frame = lipgloss.NewStyle().BorderStyle(lipgloss.RoundedBorder()).BorderForeground(Cyan).Padding(0, 1)
}

// InitFromEnv applies DetectTheme accent for the TUI process.
func InitFromEnv() ThemeInfo {
	t := DetectTheme()
	ApplyAccent(t.Name)
	return t
}
