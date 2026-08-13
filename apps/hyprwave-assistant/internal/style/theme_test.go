package style

import (
	"os"
	"path/filepath"
	"testing"
)

func TestApplyAccentNoPanic(t *testing.T) {
	ApplyAccent("verdant-haven")
	ApplyAccent("fjord-dark")
	ApplyAccent("synthwave")
	ApplyAccent("unknown-theme-xyz")
}

func TestDetectThemeEnv(t *testing.T) {
	t.Setenv("HYPRWAVE_THEME", "fjord-dark")
	info := DetectTheme()
	if info.Name != "fjord-dark" || info.Source != "env" {
		t.Fatalf("%+v", info)
	}
}

func TestDetectThemeFile(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("HOME", dir)
	t.Setenv("HYPRWAVE_THEME", "")
	cfg := filepath.Join(dir, ".config", "hyprwave")
	if err := os.MkdirAll(cfg, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(cfg, "theme"), []byte("arcade-rain\n"), 0o644); err != nil {
		t.Fatal(err)
	}
	info := DetectTheme()
	if info.Name != "arcade-rain" {
		t.Fatalf("%+v", info)
	}
}

func TestInitFromEnv(t *testing.T) {
	t.Setenv("HYPRWAVE_THEME", "cozy-harvest")
	info := InitFromEnv()
	if info.Name != "cozy-harvest" {
		t.Fatalf("%+v", info)
	}
}
