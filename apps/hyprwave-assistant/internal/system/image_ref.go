package system

import (
	"regexp"
	"strings"
)

// Common bootc status lines look like:
//
//	Image: ghcr.io/neon798/hyprwave:latest
//	Booted image: localhost/hyprwave:latest
//	● Booted image: ...
var imageRefLine = regexp.MustCompile(`(?i)(?:booted\s+)?image:\s*(\S+)`)

// ExtractImageRef best-effort parses an image reference from `bootc status` text.
func ExtractImageRef(bootcStatus string) string {
	if bootcStatus == "" {
		return ""
	}
	// Prefer first non-empty match that looks like a ref (contains / or :).
	for _, line := range strings.Split(bootcStatus, "\n") {
		m := imageRefLine.FindStringSubmatch(strings.TrimSpace(line))
		if len(m) < 2 {
			continue
		}
		ref := strings.Trim(m[1], "\"'`")
		if ref == "" || strings.EqualFold(ref, "none") {
			continue
		}
		return ref
	}
	return ""
}

// ImageRefKind classifies a container/image ref for user-facing guidance.
type ImageRefKind int

const (
	ImageRefUnknown ImageRefKind = iota
	ImageRefGHCR
	ImageRefLocalhost
	ImageRefOther
)

// ClassifyImageRef categorizes registry/local refs.
func ClassifyImageRef(ref string) ImageRefKind {
	if ref == "" {
		return ImageRefUnknown
	}
	lower := strings.ToLower(strings.TrimSpace(ref))
	// Strip transport prefixes if present (containers-storage:, oci:, docker://).
	for _, p := range []string{"docker://", "oci://", "containers-storage:"} {
		if strings.HasPrefix(lower, p) {
			lower = strings.TrimPrefix(lower, p)
		}
	}
	switch {
	case strings.Contains(lower, "ghcr.io/"):
		return ImageRefGHCR
	case strings.HasPrefix(lower, "localhost/"),
		strings.HasPrefix(lower, "localhost:"),
		strings.Contains(lower, "localhost/"):
		return ImageRefLocalhost
	default:
		return ImageRefOther
	}
}

// ImageGuidance returns short advisory copy for status/preflight/About.
// Never claims GHCR is public; localhost tags are treated as valid local builds.
func ImageGuidance(bootcStatus string) (ref string, note string) {
	ref = ExtractImageRef(bootcStatus)
	if ref == "" {
		return "", ""
	}
	switch ClassifyImageRef(ref) {
	case ImageRefGHCR:
		return ref, "GHCR image ref — package may be private; anonymous pull/upgrade can return 401/403. " +
			"Auth (if you have access) or a local rebuild/ISO may be required. " +
			"See: hyprwave-assistant kb ghcr"
	case ImageRefLocalhost:
		return ref, "localhost image ref — valid for local builds/dev (e.g. just build). " +
			"Not a public registry pull; upgrades follow this same local/private source."
	default:
		return ref, "Image upgrades follow this ref; registry auth may be required depending on visibility."
	}
}
