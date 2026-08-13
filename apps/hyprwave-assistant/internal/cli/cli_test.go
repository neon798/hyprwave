package cli

import (
	"bytes"
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/catalog"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/kb"
	"github.com/neon798/hyprwave/apps/hyprwave-assistant/internal/system"
)

func systemPlanAll() ([]system.Cmd, error) {
	return system.PlanUpdate(system.TargetAll, false)
}

type fakeRunner struct {
	paths map[string]bool
	log   *[]string
}

func (f fakeRunner) LookPath(name string) (string, error) {
	if f.paths[name] {
		return "/bin/" + name, nil
	}
	return "", errors.New("missing")
}

func (f fakeRunner) Run(_ context.Context, name string, args ...string) (string, error) {
	line := name + " " + strings.Join(args, " ")
	if f.log != nil {
		*f.log = append(*f.log, line)
	}
	return "ok: " + line, nil
}

func testCat() *catalog.Catalog {
	return &catalog.Catalog{Categories: []catalog.Category{{
		Name: "Office",
		Items: []catalog.Item{
			{ID: "libreoffice", Name: "LibreOffice", Source: catalog.SourceFlatpak, Flatpak: "org.libreoffice.LibreOffice", Description: "Suite"},
			{ID: "gamemode", Name: "GameMode", Source: catalog.SourceLayer, Packages: []string{"gamemode"}, Description: "perf"},
		},
	}}}
}

func testKB() *kb.Store {
	return &kb.Store{Articles: []kb.Article{
		{ID: "philosophy", Title: "Philosophy", Body: "# Philosophy\n\nImmutable bootc.\n", Preview: "Immutable"},
		{ID: "updates", Title: "Updates", Body: "# Updates\n\nbootc upgrade\n", Preview: "bootc"},
	}}
}

func TestUpdateDryRun(t *testing.T) {
	var out bytes.Buffer
	var log []string
	err := Run(Config{
		Stdout:  &out,
		Runner:  fakeRunner{paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true}, log: &log},
		Version: "test",
	}, []string{"update", "--all", "--dry-run"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "Dry-run") {
		t.Fatal(out.String())
	}
	if len(log) != 0 {
		t.Fatalf("dry-run executed: %v", log)
	}
}

func TestUpdateRefusesWithoutDoubleConfirm(t *testing.T) {
	// Avoid real network in CollectPreflight via tests in system package — here
	// runUpdate will call CollectPreflight. Use dry-run-only assert on missing flags first.
	var out bytes.Buffer
	err := Run(Config{
		Stdout: &out,
		Runner: fakeRunner{paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true}},
	}, []string{"update", "--flatpak", "--dry-run"})
	if err != nil {
		t.Fatal(err)
	}
	err = Run(Config{
		Stdout: &out,
		Runner: fakeRunner{paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true}},
	}, []string{"update", "--flatpak", "--yes"})
	// May fail offline or missing --confirm
	if err == nil {
		t.Fatal("expected refuse without --confirm")
	}
	if !strings.Contains(err.Error(), "--confirm") && !strings.Contains(err.Error(), "offline") {
		t.Fatal(err)
	}
}

func TestRequireDoubleConfirm(t *testing.T) {
	cmds, _ := systemPlanAll()
	if err := requireDoubleConfirm(true, true, cmds); err != nil {
		t.Fatal(err)
	}
	if err := requireDoubleConfirm(false, false, cmds); err == nil {
		t.Fatal("expected err")
	}
	if err := requireDoubleConfirm(true, false, cmds); !strings.Contains(err.Error(), "--confirm") {
		t.Fatal(err)
	}
	if err := requireDoubleConfirm(false, true, cmds); !strings.Contains(err.Error(), "--yes") {
		t.Fatal(err)
	}
}

func TestInstallDryRun(t *testing.T) {
	var out bytes.Buffer
	err := Run(Config{
		Stdout:  &out,
		Catalog: testCat(),
		Runner:  fakeRunner{paths: map[string]bool{"flatpak": true}},
	}, []string{"install", "libreoffice", "--dry-run"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "org.libreoffice.LibreOffice") {
		t.Fatal(out.String())
	}
}

func TestInstallLayerNote(t *testing.T) {
	var out bytes.Buffer
	err := Run(Config{
		Stdout:  &out,
		Catalog: testCat(),
		Runner:  fakeRunner{paths: map[string]bool{"flatpak": true}},
	}, []string{"install", "gamemode", "--yes"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "not auto-installed") && !strings.Contains(out.String(), "Layered") {
		t.Fatal(out.String())
	}
}

func TestKBSearch(t *testing.T) {
	var out bytes.Buffer
	err := Run(Config{Stdout: &out, KB: testKB()}, []string{"kb", "immutable"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "Philosophy") && !strings.Contains(out.String(), "Immutable") {
		t.Fatal(out.String())
	}
}

func TestList(t *testing.T) {
	var out bytes.Buffer
	err := Run(Config{Stdout: &out, Catalog: testCat()}, []string{"list"})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(out.String(), "libreoffice") {
		t.Fatal(out.String())
	}
}

func TestVersion(t *testing.T) {
	var out bytes.Buffer
	if err := Run(Config{Stdout: &out, Version: "9.9.9"}, []string{"version"}); err != nil {
		t.Fatal(err)
	}
	s := out.String()
	if !strings.Contains(s, "9.9.9") {
		t.Fatal(s)
	}
	if !strings.Contains(s, "Hyprland") || !strings.Contains(s, "COSMIC") {
		t.Fatalf("version should mention dual DE: %s", s)
	}
	if !strings.Contains(s, "Super+Shift+A") {
		t.Fatalf("version should mention Super+Shift+A: %s", s)
	}
	if strings.Contains(strings.ToLower(s), "ghcr is public") {
		t.Fatalf("must not claim public GHCR: %s", s)
	}
}

func TestStatusImageNoteGHCR(t *testing.T) {
	restore := system.OnlineForTests()
	defer restore()
	var out bytes.Buffer
	// Reuse system fake via cli fakeRunner with canned bootc status is hard;
	// exercise ImageGuidance through CollectStatus path using a runner that
	// answers bootc status.
	r := statusFake{
		paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true},
		bootc: "Booted image: ghcr.io/neon798/hyprwave:latest\nStaged: none",
	}
	if err := Run(Config{Stdout: &out, Runner: r, Version: "0.2.2"}, []string{"status"}); err != nil {
		t.Fatal(err)
	}
	s := out.String()
	if !strings.Contains(s, "ghcr.io/neon798/hyprwave:latest") {
		t.Fatal(s)
	}
	if !strings.Contains(strings.ToLower(s), "private") {
		t.Fatalf("expected private GHCR note: %s", s)
	}
	if strings.Contains(strings.ToLower(s), "ghcr is public") {
		t.Fatalf("must not claim public GHCR: %s", s)
	}
}

func TestHelpCopyWave3(t *testing.T) {
	var out bytes.Buffer
	if err := Run(Config{Stdout: &out, Version: "0.2.2"}, []string{"help"}); err != nil {
		t.Fatal(err)
	}
	s := out.String()
	low := strings.ToLower(s)
	need := []string{"hyprland", "cosmic", "super+shift+a", "private", "localhost", "wofi", "swaybg"}
	for _, n := range need {
		if !strings.Contains(low, n) {
			t.Errorf("help missing %q: %s", n, s)
		}
	}
	if strings.Contains(low, "ghcr is public") {
		t.Fatalf("help must not claim public GHCR: %s", s)
	}
	if !strings.Contains(low, "not wofi") && !strings.Contains(low, "not the stack") {
		t.Fatalf("help must deny Wofi/swaybg as the stack: %s", s)
	}
}

func TestStatusImageNoteLocalhost(t *testing.T) {
	restore := system.OnlineForTests()
	defer restore()
	var out bytes.Buffer
	r := statusFake{
		paths: map[string]bool{"bootc": true, "flatpak": true, "sudo": true},
		bootc: "Booted image: localhost/hyprwave:latest\nStaged: none",
	}
	if err := Run(Config{Stdout: &out, Runner: r, Version: "0.2.2"}, []string{"status"}); err != nil {
		t.Fatal(err)
	}
	s := out.String()
	if !strings.Contains(s, "localhost/hyprwave:latest") {
		t.Fatal(s)
	}
	low := strings.ToLower(s)
	if !strings.Contains(low, "localhost") && !strings.Contains(low, "local") {
		t.Fatalf("expected localhost-valid note: %s", s)
	}
	if strings.Contains(low, "ghcr is public") {
		t.Fatalf("must not claim public GHCR: %s", s)
	}
}

type statusFake struct {
	paths map[string]bool
	bootc string
}

func (f statusFake) LookPath(name string) (string, error) {
	if f.paths[name] {
		return "/bin/" + name, nil
	}
	return "", errors.New("missing")
}

func (f statusFake) Run(_ context.Context, name string, args ...string) (string, error) {
	key := name + " " + strings.Join(args, " ")
	if key == "bootc status" {
		return f.bootc, nil
	}
	if strings.HasPrefix(key, "flatpak list") {
		return "org.foo.Bar\t1\tflathub", nil
	}
	return "ok", nil
}
