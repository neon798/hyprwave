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
