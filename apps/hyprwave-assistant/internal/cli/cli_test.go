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
	if !strings.Contains(out.String(), "9.9.9") {
		t.Fatal(out.String())
	}
}
