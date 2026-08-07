// THEORETICAL EXAMPLE — DO NOT USE IN MAIN (see planning/README.md)
//
// Hyprwave Assistant skeleton: Go + Bubble Tea, tabbed TUI with the three
// planned sections (Updater / Installer / Knowledge Base), styled with the
// synthwave palette via Lip Gloss. Language decision per user 2026-07-07:
// Go (Bubble Tea), not Rust — FlatArcade stays Rust in its own repo.
package main

import (
	"fmt"
	"os"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Hyprwave palette (planning/themes/palettes.md section 0)
var (
	colBg     = lipgloss.Color("#15052e")
	colFg     = lipgloss.Color("#e0e0ff")
	colPink   = lipgloss.Color("#ff2d95")
	colCyan   = lipgloss.Color("#00f0ff")
	colPurple = lipgloss.Color("#b967ff")

	tabActive = lipgloss.NewStyle().Foreground(colBg).Background(colPink).Bold(true).Padding(0, 2)
	tabIdle   = lipgloss.NewStyle().Foreground(colPurple).Padding(0, 2)
	body      = lipgloss.NewStyle().Foreground(colFg).Padding(1, 2)
	frame     = lipgloss.NewStyle().BorderStyle(lipgloss.RoundedBorder()).BorderForeground(colCyan)
)

type tab int

const (
	tabUpdater tab = iota
	tabInstaller
	tabKnowledgeBase
	tabCount
)

var tabNames = [tabCount]string{"UPDATER", "INSTALLER", "KNOWLEDGE BASE"}

type model struct {
	active tab
}

func (m model) Init() tea.Cmd { return nil }

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	if key, ok := msg.(tea.KeyMsg); ok {
		switch key.String() {
		case "q", "ctrl+c":
			return m, tea.Quit
		case "tab", "right", "l":
			m.active = (m.active + 1) % tabCount
		case "shift+tab", "left", "h":
			m.active = (m.active + tabCount - 1) % tabCount
		}
	}
	return m, nil
}

func (m model) View() string {
	var tabs string
	for i := tab(0); i < tabCount; i++ {
		style := tabIdle
		if i == m.active {
			style = tabActive
		}
		tabs = lipgloss.JoinHorizontal(lipgloss.Top, tabs, style.Render(tabNames[i]))
	}

	var content string
	switch m.active {
	case tabUpdater:
		content = "bootc status / flatpak update — Check · Update Base · Update Flatpaks · Update All"
	case tabInstaller:
		content = "Curated catalog (catalog.toml): Office · Gaming · Networking · Privacy — one-click installs"
	case tabKnowledgeBase:
		content = "Fuzzy-searchable KB (kb/*.md): immutability, theming, variants, troubleshooting"
	}

	return frame.Render(lipgloss.JoinVertical(lipgloss.Left, tabs, body.Render(content))) + "\n"
}

func main() {
	if _, err := tea.NewProgram(model{}, tea.WithAltScreen()).Run(); err != nil {
		fmt.Fprintln(os.Stderr, "hyprwave-assistant:", err)
		os.Exit(1)
	}
}
