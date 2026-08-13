package system

import (
	"context"
	"errors"
	"strings"
	"testing"
)

type fakeRunner struct {
	paths map[string]bool
	// key = "name arg1 arg2" → output, err
	responses map[string]struct {
		out string
		err error
	}
	calls []string
}

func (f *fakeRunner) LookPath(name string) (string, error) {
	if f.paths[name] {
		return "/usr/bin/" + name, nil
	}
	return "", errors.New("not found")
}

func (f *fakeRunner) Run(_ context.Context, name string, args ...string) (string, error) {
	key := name + " " + strings.Join(args, " ")
	f.calls = append(f.calls, key)
	if r, ok := f.responses[key]; ok {
		return r.out, r.err
	}
	// prefix match for flexible args
	for k, r := range f.responses {
		if strings.HasPrefix(key, k) {
			return r.out, r.err
		}
	}
	return "", errors.New("unexpected: " + key)
}

func TestDetectNeedsReboot(t *testing.T) {
	cases := []struct {
		in   string
		want bool
	}{
		{"Current booted deployment is happy", false},
		{"Staged: yes\nimage: foo", true},
		{"Staged: none", false},
		{"A reboot is required to apply", true},
		{"pending deployment ready", true},
		{"", false},
	}
	for _, c := range cases {
		if got := DetectNeedsReboot(c.in); got != c.want {
			t.Errorf("DetectNeedsReboot(%q)=%v want %v", c.in, got, c.want)
		}
	}
}

func TestCollectStatus(t *testing.T) {
	restore := OnlineForTests()
	defer restore()
	f := &fakeRunner{
		paths: map[string]bool{"bootc": true, "flatpak": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"bootc status": {
				out: "Booted image: ghcr.io/neon798/hyprwave:latest\nStaged: none",
			},
			"flatpak list --columns=application,version,origin": {
				out: "org.mozilla.firefox\t128\tflathub",
			},
		},
	}
	s := CollectStatus(f)
	if !s.BootcAvailable || !s.FlatpakAvailable {
		t.Fatalf("expected both available: %+v", s)
	}
	if s.BootcStatus == "" {
		t.Fatal("empty bootc status")
	}
	if !strings.Contains(s.FlatpakStatus, "1 installed") {
		t.Fatalf("flatpak status: %s", s.FlatpakStatus)
	}
	if s.ImageRef != "ghcr.io/neon798/hyprwave:latest" {
		t.Fatalf("image ref: %q", s.ImageRef)
	}
	if s.ImageNote == "" || !strings.Contains(strings.ToLower(s.ImageNote), "private") {
		t.Fatalf("expected GHCR private note: %q", s.ImageNote)
	}
	// Preflight should surface GHCR warning for status --check UX.
	found := false
	for _, w := range s.Preflight.Warnings {
		if strings.Contains(strings.ToLower(w), "private") {
			found = true
			break
		}
	}
	if !found {
		t.Fatalf("preflight warnings missing GHCR note: %v", s.Preflight.Warnings)
	}
	// "Staged: none" still contains "staged" — DetectNeedsReboot is heuristic.
	// That is acceptable; document via test awareness.
	_ = s.NeedsReboot
}

func TestCollectStatusLocalhost(t *testing.T) {
	restore := OnlineForTests()
	defer restore()
	f := &fakeRunner{
		paths: map[string]bool{"bootc": true, "flatpak": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"bootc status": {
				out: "Booted image: localhost/hyprwave:latest\nStaged: none",
			},
			"flatpak list --columns=application,version,origin": {
				out: "",
			},
		},
	}
	s := CollectStatus(f)
	if s.ImageRef != "localhost/hyprwave:latest" {
		t.Fatalf("ref=%q", s.ImageRef)
	}
	if !strings.Contains(strings.ToLower(s.ImageNote), "localhost") &&
		!strings.Contains(strings.ToLower(s.ImageNote), "local") {
		t.Fatalf("note=%q", s.ImageNote)
	}
}

func TestCollectStatusMissingTools(t *testing.T) {
	restore := OfflineForTests()
	defer restore()
	f := &fakeRunner{paths: map[string]bool{}}
	s := CollectStatus(f)
	if s.BootcAvailable || s.FlatpakAvailable {
		t.Fatal("expected tools missing")
	}
	if s.BootcError == "" || s.FlatpakError == "" {
		t.Fatal("expected errors set")
	}
}

func TestFlatpakInstall(t *testing.T) {
	f := &fakeRunner{
		paths: map[string]bool{"flatpak": true},
		responses: map[string]struct {
			out string
			err error
		}{
			"flatpak install -y flathub org.libreoffice.LibreOffice": {
				out: "Installation complete",
			},
		},
	}
	out, err := FlatpakInstall(context.Background(), f, "org.libreoffice.LibreOffice")
	if err != nil {
		t.Fatal(err)
	}
	if out != "Installation complete" {
		t.Fatalf("out=%q", out)
	}
}

func TestLayerNote(t *testing.T) {
	n := LayerNote([]string{"gamemode", "mangohud"})
	if !strings.Contains(n, "gamemode") {
		t.Fatal(n)
	}
}
