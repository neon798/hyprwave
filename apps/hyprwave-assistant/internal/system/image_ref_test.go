package system

import (
	"strings"
	"testing"
)

func TestExtractImageRef(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{"Booted image: ghcr.io/neon798/hyprwave:latest\nStaged: none", "ghcr.io/neon798/hyprwave:latest"},
		{"● Booted image: localhost/hyprwave:latest", "localhost/hyprwave:latest"},
		{"Image: localhost/hyprwave-cosmic:dev\n", "localhost/hyprwave-cosmic:dev"},
		{"no image here", ""},
		{"", ""},
	}
	for _, c := range cases {
		got := ExtractImageRef(c.in)
		if got != c.want {
			t.Fatalf("ExtractImageRef(%q)=%q want %q", c.in, got, c.want)
		}
	}
}

func TestClassifyAndGuidance(t *testing.T) {
	if ClassifyImageRef("ghcr.io/neon798/hyprwave:latest") != ImageRefGHCR {
		t.Fatal("ghcr")
	}
	if ClassifyImageRef("localhost/hyprwave:latest") != ImageRefLocalhost {
		t.Fatal("localhost")
	}

	ref, note := ImageGuidance("Booted image: ghcr.io/neon798/hyprwave:latest\n")
	if ref == "" || note == "" {
		t.Fatal("expected ghcr note")
	}
	low := strings.ToLower(note)
	if !strings.Contains(low, "private") {
		t.Fatalf("note missing private: %s", note)
	}
	if strings.Contains(low, "ghcr is public") || strings.Contains(low, "publicly available") {
		t.Fatalf("must not claim public GHCR: %s", note)
	}
	if !strings.Contains(low, "401") && !strings.Contains(low, "403") {
		t.Fatalf("expected 401/403 mention: %s", note)
	}

	ref, note = ImageGuidance("Booted image: localhost/hyprwave:latest\n")
	if ClassifyImageRef(ref) != ImageRefLocalhost {
		t.Fatal(ref)
	}
	low = strings.ToLower(note)
	if !strings.Contains(low, "localhost") && !strings.Contains(low, "local") {
		t.Fatalf("localhost note: %s", note)
	}
}
