// Package style holds the Hyprwave synthwave Lip Gloss palette and shared chrome.
package style

import "github.com/charmbracelet/lipgloss"

// Synthwave palette (matches /usr/share/hyprwave themes default).
var (
	Bg     = lipgloss.Color("#15052e")
	Fg     = lipgloss.Color("#e0e0ff")
	Pink   = lipgloss.Color("#ff2d95")
	Cyan   = lipgloss.Color("#00f0ff")
	Purple = lipgloss.Color("#b967ff")
	Dim    = lipgloss.Color("#6b5a8a")
	Warn   = lipgloss.Color("#ffcc00")
	OK     = lipgloss.Color("#00ff9f")
	Err    = lipgloss.Color("#ff4466")
)

var (
	TabActive = lipgloss.NewStyle().
			Foreground(Bg).
			Background(Pink).
			Bold(true).
			Padding(0, 2)

	TabIdle = lipgloss.NewStyle().
		Foreground(Purple).
		Padding(0, 2)

	Title = lipgloss.NewStyle().
		Foreground(Cyan).
		Bold(true)

	Body = lipgloss.NewStyle().
		Foreground(Fg)

	Muted = lipgloss.NewStyle().
		Foreground(Dim)

	Selected = lipgloss.NewStyle().
			Foreground(Bg).
			Background(Cyan).
			Bold(true)

	Highlight = lipgloss.NewStyle().
			Foreground(Pink).
			Bold(true)

	Warning = lipgloss.NewStyle().
		Foreground(Warn).
		Bold(true)

	Success = lipgloss.NewStyle().
		Foreground(OK)

	Error = lipgloss.NewStyle().
		Foreground(Err).
		Bold(true)

	Frame = lipgloss.NewStyle().
		BorderStyle(lipgloss.RoundedBorder()).
		BorderForeground(Cyan).
		Padding(0, 1)

	Help = lipgloss.NewStyle().
		Foreground(Dim)

	StatusOK = lipgloss.NewStyle().Foreground(OK)
	StatusBad = lipgloss.NewStyle().Foreground(Err)
	StatusWarn = lipgloss.NewStyle().Foreground(Warn)
)

// RenderTabs draws horizontal tab bar; active is 0-based index.
func RenderTabs(names []string, active int) string {
	parts := make([]string, 0, len(names))
	for i, name := range names {
		if i == active {
			parts = append(parts, TabActive.Render(name))
		} else {
			parts = append(parts, TabIdle.Render(name))
		}
	}
	return lipgloss.JoinHorizontal(lipgloss.Top, parts...)
}
