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

func TestShippedKBWave3Copy(t *testing.T) {
	dir := shippedKBDir(t)
	s, err := LoadDir(dir)
	if err != nil {
		t.Fatal(err)
	}

	forbidPublic := []string{"ghcr is public", "publicly available on ghcr", "ghcr is open"}
	for _, a := range s.Articles {
		low := strings.ToLower(a.Body)
		for _, bad := range forbidPublic {
			if strings.Contains(low, bad) {
				t.Errorf("%s.md claims public GHCR (%q)", a.ID, bad)
			}
		}
	}

	ghcr := s.Get("ghcr")
	if ghcr == nil {
		t.Fatal("missing ghcr")
	}
	glow := strings.ToLower(ghcr.Body)
	for _, n := range []string{"private", "401", "403", "localhost", "localhost/hyprwave"} {
		if !strings.Contains(glow, n) {
			t.Errorf("ghcr.md missing %q", n)
		}
	}
	if !strings.Contains(glow, "may be private") && !strings.Contains(glow, "may still be private") {
		t.Error("ghcr.md must say packages may be private")
	}

	variants := s.Get("variants")
	if variants == nil {
		t.Fatal("missing variants")
	}
	vlow := strings.ToLower(variants.Body)
	if !strings.Contains(vlow, "hyprland") || !strings.Contains(vlow, "cosmic") {
		t.Error("variants.md must describe dual DE (Hyprland + COSMIC)")
	}
	if !strings.Contains(vlow, "super+shift+a") {
		t.Error("variants.md must mention Super+Shift+A")
	}
	if !strings.Contains(vlow, "private") {
		t.Error("variants.md must mention private GHCR")
	}

	keys := s.Get("keybindings")
	if keys == nil {
		t.Fatal("missing keybindings")
	}
	if !strings.Contains(strings.ToLower(keys.Body), "super+shift+a") {
		t.Error("keybindings.md must document Super+Shift+A")
	}

	duress := s.Get("duress")
	if duress == nil {
		t.Fatal("missing duress")
	}
	dlow := strings.ToLower(duress.Body)
	if !strings.Contains(dlow, "off by default") && !strings.Contains(dlow, "not enabled") {
		t.Error("duress.md must say OFF / not enabled")
	}
	if strings.Contains(dlow, "enabled in the stock") || strings.Contains(dlow, "duress is enabled") {
		t.Error("duress.md must not claim duress is enabled")
	}

	// Wofi/swaybg only as denials — not the shipped stack.
	for _, a := range s.Articles {
		low := strings.ToLower(a.Body)
		for _, needle := range []string{"wofi", "swaybg"} {
			if !strings.Contains(low, needle) {
				continue
			}
			if !strings.Contains(low, "not") && !strings.Contains(low, "never") {
				t.Errorf("%s.md mentions %s without a denial", a.ID, needle)
			}
		}
	}
}
