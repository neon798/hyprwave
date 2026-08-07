package catalog

import (
	"os"
	"path/filepath"
	"testing"
)

const sample = `
[[category]]
name = "Office"
items = [
  { id = "libreoffice", name = "LibreOffice", source = "flathub", flatpak = "org.libreoffice.LibreOffice", description = "Suite" },
]

[[category]]
name = "Gaming"
items = [
  { id = "gamemode", name = "GameMode", source = "layer", packages = ["gamemode"], description = "Perf" },
]
`

func TestLoadAndFind(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "catalog.toml")
	if err := os.WriteFile(path, []byte(sample), 0o644); err != nil {
		t.Fatal(err)
	}
	c, err := Load(path)
	if err != nil {
		t.Fatal(err)
	}
	if len(c.Categories) != 2 {
		t.Fatalf("cats=%d", len(c.Categories))
	}
	it := c.Find("libreoffice")
	if it == nil || it.Flatpak != "org.libreoffice.LibreOffice" {
		t.Fatalf("find libreoffice: %+v", it)
	}
	layer := c.Find("gamemode")
	if layer == nil || layer.Source != SourceLayer {
		t.Fatalf("layer: %+v", layer)
	}
	if got := it.InstallLabel(); got != "flatpak org.libreoffice.LibreOffice" {
		t.Fatalf("label=%q", got)
	}
	flat := c.FlatList()
	if len(flat) != 2 {
		t.Fatalf("flat=%d", len(flat))
	}
}

func TestLoadFromDirs(t *testing.T) {
	dir := t.TempDir()
	if err := os.WriteFile(filepath.Join(dir, "catalog.toml"), []byte(sample), 0o644); err != nil {
		t.Fatal(err)
	}
	c, err := LoadFromDirs([]string{"/nonexistent", dir})
	if err != nil {
		t.Fatal(err)
	}
	if c.Find("libreoffice") == nil {
		t.Fatal("missing item")
	}
}

func TestShippedCatalog(t *testing.T) {
	// Resolve repo asset from module location.
	candidates := []string{
		filepath.Join("..", "..", "..", "build_files", "usr", "share", "hyprwave", "assistant", "catalog.toml"),
		filepath.Join("build_files", "usr", "share", "hyprwave", "assistant", "catalog.toml"),
	}
	var c *Catalog
	var err error
	for _, p := range candidates {
		c, err = Load(p)
		if err == nil {
			break
		}
	}
	if err != nil {
		t.Skip("shipped catalog not found from test cwd:", err)
	}
	if len(c.Categories) < 5 {
		t.Fatalf("expected expanded catalog, cats=%d", len(c.Categories))
	}
	for _, row := range c.FlatList() {
		it := row.Item
		if it.ID == "" || it.Name == "" {
			t.Fatalf("empty id/name: %+v", it)
		}
		switch it.Source {
		case SourceFlatpak:
			if it.Flatpak == "" || !containsDot(it.Flatpak) {
				t.Fatalf("bad flatpak id for %s: %q", it.ID, it.Flatpak)
			}
		case SourceLayer:
			if len(it.Packages) == 0 {
				t.Fatalf("layer with no packages: %s", it.ID)
			}
		default:
			t.Fatalf("unknown source %q on %s", it.Source, it.ID)
		}
	}
	if c.Find("libreoffice") == nil || c.Find("gimp") == nil {
		t.Fatal("expected libreoffice and gimp entries")
	}
}

func containsDot(s string) bool {
	for i := 0; i < len(s); i++ {
		if s[i] == '.' {
			return true
		}
	}
	return false
}
