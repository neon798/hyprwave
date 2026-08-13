package catalog

import (
	"os"
	"path/filepath"
	"strings"
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
	if probs := c.Validate(); len(probs) != 0 {
		t.Fatalf("shipped catalog invalid: %v", probs)
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

func TestValidFlatpakID(t *testing.T) {
	ok := []string{"org.libreoffice.LibreOffice", "com.valvesoftware.Steam", "io.gitlab.librewolf-community"}
	bad := []string{"", "foo", "a.b", "has space.not.ok", "org..empty"}
	for _, id := range ok {
		if !ValidFlatpakID(id) {
			t.Fatalf("want valid: %s", id)
		}
	}
	for _, id := range bad {
		if ValidFlatpakID(id) {
			t.Fatalf("want invalid: %s", id)
		}
	}
}

func TestCatalogValidateAndLabels(t *testing.T) {
	c := &Catalog{Categories: []Category{
		{Name: "X", Items: []Item{
			{ID: "a", Name: "A", Source: SourceFlatpak, Flatpak: "org.a.App"},
			{ID: "b", Name: "B", Source: SourceLayer, Packages: []string{"pkg"}},
		}},
	}}
	if probs := c.Validate(); len(probs) != 0 {
		t.Fatal(probs)
	}
	if c.Find("a").InstallLabel() != "flatpak org.a.App" {
		t.Fatal(c.Find("a").InstallLabel())
	}
	if !strings.Contains(c.Find("b").InstallLabel(), "layer:") {
		t.Fatal(c.Find("b").InstallLabel())
	}
	// empty flatpak label branch
	empty := Item{Source: SourceFlatpak}
	if empty.InstallLabel() != "flatpak" {
		t.Fatal(empty.InstallLabel())
	}
	layerEmpty := Item{Source: SourceLayer}
	if layerEmpty.InstallLabel() != "layer" {
		t.Fatal(layerEmpty.InstallLabel())
	}
	other := Item{Source: "other"}
	if other.InstallLabel() != "other" {
		t.Fatal("other")
	}
	bad := &Catalog{Categories: []Category{{Name: "Y", Items: []Item{
		{ID: "x", Source: SourceFlatpak, Flatpak: "bad"},
		{ID: "x", Source: SourceLayer},
	}}}}
	if len(bad.Validate()) < 2 {
		t.Fatal(bad.Validate())
	}
	var nc *Catalog
	if len(nc.Validate()) == 0 {
		t.Fatal("nil catalog")
	}
	if nc.Find("x") != nil {
		t.Fatal("nil find")
	}
	if len(nc.FlatList()) != 0 {
		t.Fatal("nil flat")
	}
	_ = strings.Contains
}
