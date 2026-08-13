package style

import "github.com/charmbracelet/lipgloss"

// CyanSearch styles an inline search/filter prompt.
func CyanSearch(s string) string {
	return lipgloss.NewStyle().Foreground(Cyan).Bold(true).Render(s)
}
