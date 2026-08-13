package system

import (
	"errors"
	"strings"
	"testing"
)

func TestCollectPreflightOffline(t *testing.T) {
	restore := OfflineForTests()
	defer restore()

	f := &fakeRunner{paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true}}
	p := CollectPreflight(f)
	if p.Online {
		t.Fatal("expected offline")
	}
	if p.OfflineBanner() == "" {
		t.Fatal("expected offline banner")
	}
	if !p.CanMutateBase() {
		t.Fatal("bootc+sudo should allow base mutate attempt")
	}
	if !p.CanMutateFlatpak() {
		t.Fatal("flatpak present")
	}
	s := p.Summary()
	if !strings.Contains(s, "online:     no") {
		t.Fatal(s)
	}
	if !strings.Contains(s, "cannot reach") {
		t.Fatal(s)
	}
}

func TestCollectPreflightMissingTools(t *testing.T) {
	restore := OnlineForTests()
	defer restore()
	f := &fakeRunner{paths: map[string]bool{}}
	p := CollectPreflight(f)
	if p.CanMutateBase() || p.CanMutateFlatpak() {
		t.Fatal("expected no mutate")
	}
	if len(p.Warnings) < 2 {
		t.Fatalf("warnings: %v", p.Warnings)
	}
	if p.OfflineBanner() != "" {
		t.Fatal("online should have empty banner")
	}
}

func TestClassifyErrorMore(t *testing.T) {
	if ClassifyError(nil, "x") != nil {
		t.Fatal("nil")
	}
	e := ClassifyError(errors.New("polkit interactive authentication required"), "bootc")
	if !strings.Contains(e.Error(), "elevated") {
		t.Fatal(e)
	}
	e = ClassifyError(errors.New("bootc: not found"), "bootc")
	if !strings.Contains(e.Error(), "not available") {
		t.Fatal(e)
	}
	e = ClassifyError(errors.New("weird"), "op")
	if !strings.Contains(e.Error(), "op failed") {
		t.Fatal(e)
	}
}

func TestRootOrSudoHintAndEnvHome(t *testing.T) {
	_ = RootOrSudoHint()
	_ = EnvHome()
	_ = yn(true)
	_ = yn(false)
}
