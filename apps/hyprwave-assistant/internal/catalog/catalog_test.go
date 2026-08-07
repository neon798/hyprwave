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
