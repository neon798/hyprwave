package kb

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestLoadAndSearch(t *testing.T) {
	dir := t.TempDir()
	write := func(name, body string) {
		if err := os.WriteFile(filepath.Join(dir, name), []byte(body), 0o644); err != nil {
			t.Fatal(err)
		}
	}
	write("philosophy.md", "# Hyprwave Philosophy\n\nImmutable bootc image.\n")
	write("updates.md", "# How Updates Work\n\nUse bootc upgrade then reboot.\n")
	write("duress.md", "# Duress Password\n\nComing soon.\n")

	s, err := LoadDir(dir)
	if err != nil {
		t.Fatal(err)
	}
	if len(s.Articles) != 3 {
		t.Fatalf("got %d articles", len(s.Articles))
	}
	all := s.Search("")
	if len(all) != 3 {
		t.Fatalf("search empty: %d", len(all))
	}
	hits := s.Search("immutable")
	if len(hits) == 0 {
		t.Fatal("expected fuzzy hit on immutable")
	}
	if !strings.Contains(hits[0].Body, "Immutable") && hits[0].ID != "philosophy" {
		// fuzzy may rank differently; ensure philosophy is among hits
		found := false
		for _, h := range hits {
			if h.ID == "philosophy" {
				found = true
			}
		}
		if !found {
			t.Fatalf("philosophy not in hits: %+v", hits)
		}
	}
	a := s.Get("updates")
	if a == nil || a.Title != "How Updates Work" {
		t.Fatalf("get updates: %+v", a)
	}
}

func shippedKBDir(t *testing.T) string {
	t.Helper()
	candidates := []string{
		filepath.Join("..", "..", "..", "build_files", "usr", "share", "hyprwave", "assistant", "kb"),
		filepath.Join("build_files", "usr", "share", "hyprwave", "assistant", "kb"),
	}
	for _, p := range candidates {
		if st, err := os.Stat(p); err == nil && st.IsDir() {
			return p
		}
	}
	t.Skip("shipped kb dir not found from test cwd")
	return ""
}

func TestShippedKBMatchesOS(t *testing.T) {
	dir := shippedKBDir(t)
	s, err := LoadDir(dir)
	if err != nil {
		t.Fatal(err)
	}
	required := []string{"first-boot", "ghcr", "variants", "theming", "duress", "walker", "hyprpaper", "keybindings"}
	for _, id := range required {
		if s.Get(id) == nil {
			t.Errorf("missing required article %q", id)
		}
	}

	var corpus strings.Builder
	for _, a := range s.Articles {
		corpus.WriteString(a.Body)
		corpus.WriteByte('\n')
	}
	all := strings.ToLower(corpus.String())

	if strings.Contains(all, "pending merge") {
		t.Error("KB still claims pending merge")
	}
	if strings.Contains(all, "assistant not installed") {
		t.Error("KB still claims assistant not installed")
	}

	// Wofi/swaybg may appear only as denials.
	for _, needle := range []string{"wofi", "swaybg"} {
		if !strings.Contains(all, needle) {
			continue
		}
		for _, a := range s.Articles {
			low := strings.ToLower(a.Body)
			if !strings.Contains(low, needle) {
				continue
			}
			if !strings.Contains(low, "not") {
				t.Errorf("%s.md mentions %s without a denial", a.ID, needle)
			}
		}
	}

	duress := s.Get("duress")
	if duress == nil {
		t.Fatal("missing duress")
	}
	dlow := strings.ToLower(duress.Body)
	if !strings.Contains(dlow, "off") || strings.Contains(dlow, "enabled in the stock") {
		t.Error("duress.md must describe stock as OFF, not enabled")
	}

	needles := []string{
		"super+shift+a",
		"walker",
		"hyprpaper",
		"11",
		"new users",
		"private",
	}
	for _, n := range needles {
		if !strings.Contains(all, n) {
			t.Errorf("shipped KB corpus missing %q", n)
		}
	}
}
