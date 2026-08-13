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
	if c.Find("discord") == nil || c.Find("discord").Flatpak != "com.discordapp.Discord" {
		t.Fatal("expected verified Discord Flatpak id")
	}
	if c.Find("thunderbird") == nil || c.Find("thunderbird").Flatpak != "org.mozilla.Thunderbird" {
		t.Fatal("expected verified Thunderbird Flatpak id")
	}
	if probs := c.Validate(); len(probs) != 0 {
		t.Fatalf("shipped catalog invalid: %v", probs)
	}
}

// knownFlathubIDs are real Flathub app IDs shipped in catalog.toml.
// Do not invent IDs — change this table only to match published Flathub apps.
var knownFlathubIDs = map[string]string{
	"libreoffice":     "org.libreoffice.LibreOffice",
	"onlyoffice":      "org.onlyoffice.desktopeditors",
	"obsidian":        "md.obsidian.Obsidian",
	"joplin":          "net.cozic.joplin_desktop",
	"thunderbird":     "org.mozilla.Thunderbird",
	"steam":           "com.valvesoftware.Steam",
	"heroic":          "com.heroicgameslauncher.hgl",
	"lutris":          "net.lutris.Lutris",
	"bottles":         "com.usebottles.bottles",
	"tailscale":       "io.tailscale.ipn",
	"syncthing":       "com.github.zocker_160.SyncThingy",
	"remmina":         "org.remmina.Remmina",
	"librewolf":       "io.gitlab.librewolf-community",
	"mullvad-browser": "net.mullvad.MullvadBrowser",
	"tor-browser":     "org.torproject.torbrowser-launcher",
	"firefox":         "org.mozilla.firefox",
	"vscodium":        "com.vscodium.codium",
	"zed":             "dev.zed.Zed",
	"podman-desktop":  "io.podman_desktop.PodmanDesktop",
	"mullvad-vpn":     "net.mullvad.MullvadVPN",
	"protonvpn":       "com.protonvpn.www",
	"bitwarden":       "com.bitwarden.desktop",
	"keepassxc":       "org.keepassxc.KeePassXC",
	"element":         "im.riot.Riot",
	"signal":          "org.signal.Signal",
	"telegram":        "org.telegram.desktop",
	"discord":         "com.discordapp.Discord",
	"spotify":         "com.spotify.Client",
	"jellyfin-mp":     "com.github.iwalton3.jellyfin-media-player",
	"vlc":             "org.videolan.VLC",
	"obs":             "com.obsproject.Studio",
	"gimp":            "org.gimp.GIMP",
	"inkscape":        "org.inkscape.Inkscape",
	"krita":           "org.kde.krita",
	"blender":         "org.blender.Blender",
}

func loadShippedCatalog(t *testing.T) *Catalog {
	t.Helper()
	candidates := []string{
		filepath.Join("..", "..", "..", "build_files", "usr", "share", "hyprwave", "assistant", "catalog.toml"),
		filepath.Join("build_files", "usr", "share", "hyprwave", "assistant", "catalog.toml"),
	}
	for _, p := range candidates {
		c, err := Load(p)
		if err == nil {
			return c
		}
	}
	t.Skip("shipped catalog not found from test cwd")
	return nil
}

func TestShippedCatalogKnownFlathubIDs(t *testing.T) {
	c := loadShippedCatalog(t)
	for id, want := range knownFlathubIDs {
		it := c.Find(id)
		if it == nil {
			t.Errorf("missing catalog id %q (expected real Flathub %s)", id, want)
			continue
		}
		if it.Source != SourceFlatpak {
			t.Errorf("%s: source=%q want flathub", id, it.Source)
		}
		if it.Flatpak != want {
			t.Errorf("%s: flatpak=%q want known real ID %q", id, it.Flatpak, want)
		}
		if !ValidFlatpakID(it.Flatpak) {
			t.Errorf("%s: %q failed ValidFlatpakID", id, it.Flatpak)
		}
	}
	// Every shipped flathub row must be in the known-real table (no invented IDs).
	for _, row := range c.FlatList() {
		it := row.Item
		if it.Source != SourceFlatpak {
			continue
		}
		want, ok := knownFlathubIDs[it.ID]
		if !ok {
			t.Errorf("catalog id %q (%s) not in knownFlathubIDs — do not invent Flathub IDs", it.ID, it.Flatpak)
			continue
		}
		if it.Flatpak != want {
			t.Errorf("%s drifted from known ID: got %q want %q", it.ID, it.Flatpak, want)
		}
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
