package ui

import (
	"context"
	"strings"
	"testing"

	tea "github.com/charmbracelet/bubbletea"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
)

type stubRunner struct{}

func (stubRunner) LookPath(name string) (string, error) {
	return "/bin/" + name, nil
}

func (stubRunner) Run(_ context.Context, name string, args ...string) (string, error) {
	return name + " " + strings.Join(args, " ") + "\nok", nil
}

func testCatalog() *catalog.Catalog {
	return &catalog.Catalog{
		Categories: []catalog.Category{
			{
				Name: "Office",
				Items: []catalog.Item{
					{ID: "libreoffice", Name: "LibreOffice", Source: catalog.SourceFlatpak, Flatpak: "org.libreoffice.LibreOffice", Description: "Suite"},
				},
			},
		},
	}
}

func testKB() *kb.Store {
	return &kb.Store{
		Articles: []kb.Article{
			{ID: "philosophy", Title: "Philosophy", Body: "# Philosophy\n\nImmutable.", Preview: "Immutable."},
			{ID: "updates", Title: "Updates", Body: "# Updates\n\nbootc upgrade", Preview: "bootc upgrade"},
		},
	}
}

func TestTabNavigation(t *testing.T) {
	m := New(Config{Runner: stubRunner{}, Catalog: testCatalog(), KB: testKB(), Version: "test"})
	if m.active != tabUpdater {
		t.Fatal("start updater")
	}
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyTab})
	m = nm.(Model)
	if m.active != tabInstaller {
		t.Fatalf("tab -> installer, got %d", m.active)
	}
	nm, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'3'}})
	m = nm.(Model)
	if m.active != tabKB {
		t.Fatalf("3 -> kb, got %d", m.active)
	}
	nm, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'4'}})
	m = nm.(Model)
	view := m.View()
	if !strings.Contains(view, "About") && !strings.Contains(view, "ABOUT") {
		// About tab content
		if m.active != tabAbout {
			t.Fatalf("active=%d view=%s", m.active, view)
		}
	}
}

func TestConfirmBaseUpdate(t *testing.T) {
	m := New(Config{Runner: stubRunner{}, Catalog: testCatalog(), KB: testKB()})
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'b'}})
	m = nm.(Model)
	if m.confirm == nil || m.confirm.action != actionUpdateBase {
		t.Fatalf("expected confirm base: %+v", m.confirm)
	}
	if !m.confirm.danger {
		t.Fatal("expected reboot danger flag")
	}
	view := m.View()
	if !strings.Contains(view, "REBOOT") && !strings.Contains(view, "reboot") {
		t.Fatalf("confirm view missing reboot warning: %s", view)
	}
	// cancel
	nm, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'n'}})
	m = nm.(Model)
	if m.confirm != nil {
		t.Fatal("confirm should clear")
	}
}

func TestInstallerFilter(t *testing.T) {
	m := New(Config{Runner: stubRunner{}, Catalog: testCatalog(), KB: testKB()})
	m.active = tabInstaller
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{'/'}})
	m = nm.(Model)
	if !m.filtering {
		t.Fatal("filtering")
	}
	for _, r := range "libre" {
		nm, _ = m.Update(tea.KeyMsg{Type: tea.KeyRunes, Runes: []rune{r}})
		m = nm.(Model)
	}
	items := m.visibleInstallItems()
	if len(items) != 1 {
		t.Fatalf("filter items=%d", len(items))
	}
}

func TestStatusMsg(t *testing.T) {
	m := New(Config{Runner: stubRunner{}, Catalog: testCatalog(), KB: testKB()})
	st := system.CollectStatus(stubRunner{})
	nm, _ := m.Update(statusMsg{status: st})
	m = nm.(Model)
	if !m.statusLoaded {
		t.Fatal("not loaded")
	}
	view := m.View()
	if !strings.Contains(view, "bootc") && !strings.Contains(strings.ToLower(view), "base") {
		t.Fatalf("updater view: %s", view)
	}
}

func TestKBOpen(t *testing.T) {
	m := New(Config{Runner: stubRunner{}, Catalog: testCatalog(), KB: testKB()})
	m.active = tabKB
	nm, _ := m.Update(tea.KeyMsg{Type: tea.KeyEnter})
	m = nm.(Model)
	if !m.kbReading {
		t.Fatal("expected reading")
	}
	view := m.View()
	if !strings.Contains(view, "Immutable") && !strings.Contains(view, "Philosophy") {
		t.Fatalf("kb view: %s", view)
	}
}
