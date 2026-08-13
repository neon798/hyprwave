// Package catalog loads the curated installer catalog (TOML).
package catalog

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/BurntSushi/toml"
)

// Source of an installable item.
type Source string

const (
	SourceFlatpak Source = "flathub"
	SourceLayer   Source = "layer"
)

// Item is one software entry in the catalog.
type Item struct {
	ID          string   `toml:"id"`
	Name        string   `toml:"name"`
	Source      Source   `toml:"source"`
	Flatpak     string   `toml:"flatpak"`
	Packages    []string `toml:"packages"`
	Description string   `toml:"description"`
}

// Category groups items.
type Category struct {
	Name  string `toml:"name"`
	Items []Item `toml:"items"`
}

// Catalog is the full installer list.
type Catalog struct {
	Categories []Category `toml:"category"`
}

// Load reads catalog.toml from path.
func Load(path string) (*Catalog, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("read catalog: %w", err)
	}
	var c Catalog
	if _, err := toml.Decode(string(data), &c); err != nil {
		return nil, fmt.Errorf("parse catalog: %w", err)
	}
	return &c, nil
}

// LoadFromDirs tries each directory for catalog.toml; first hit wins.
func LoadFromDirs(dirs []string) (*Catalog, error) {
	var errs []string
	for _, d := range dirs {
		p := filepath.Join(d, "catalog.toml")
		c, err := Load(p)
		if err == nil {
			return c, nil
		}
		errs = append(errs, fmt.Sprintf("%s: %v", p, err))
	}
	return nil, fmt.Errorf("catalog not found:\n  %s", strings.Join(errs, "\n  "))
}

// FlatList returns (categoryName, item) for every item.
func (c *Catalog) FlatList() []struct {
	Category string
	Item     Item
} {
	var out []struct {
		Category string
		Item     Item
	}
	if c == nil {
		return out
	}
	for _, cat := range c.Categories {
		for _, it := range cat.Items {
			out = append(out, struct {
				Category string
				Item     Item
			}{Category: cat.Name, Item: it})
		}
	}
	return out
}

// Find returns the item with the given id, or nil.
func (c *Catalog) Find(id string) *Item {
	if c == nil {
		return nil
	}
	for _, cat := range c.Categories {
		for i := range cat.Items {
			if cat.Items[i].ID == id {
				return &cat.Items[i]
			}
		}
	}
	return nil
}

// InstallLabel is a short human description of how the item installs.
func (it Item) InstallLabel() string {
	switch it.Source {
	case SourceFlatpak:
		if it.Flatpak != "" {
			return "flatpak " + it.Flatpak
		}
		return "flatpak"
	case SourceLayer:
		if len(it.Packages) > 0 {
			return "layer: " + strings.Join(it.Packages, ", ")
		}
		return "layer"
	default:
		return string(it.Source)
	}
}

// ValidFlatpakID checks reverse-DNS style Flathub application ids.
// Example: org.libreoffice.LibreOffice
func ValidFlatpakID(id string) bool {
	id = strings.TrimSpace(id)
	if id == "" || strings.Contains(id, " ") {
		return false
	}
	parts := strings.Split(id, ".")
	if len(parts) < 3 {
		return false
	}
	for _, p := range parts {
		if p == "" {
			return false
		}
		for _, r := range p {
			if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') || r == '_' || r == '-' {
				continue
			}
			return false
		}
	}
	return true
}

// Validate reports structural problems in the catalog (for tests / CI).
func (c *Catalog) Validate() []string {
	var problems []string
	if c == nil {
		return []string{"catalog is nil"}
	}
	seen := map[string]bool{}
	for _, cat := range c.Categories {
		if cat.Name == "" {
			problems = append(problems, "category with empty name")
		}
		for _, it := range cat.Items {
			if it.ID == "" {
				problems = append(problems, "item with empty id in "+cat.Name)
			}
			if seen[it.ID] {
				problems = append(problems, "duplicate id: "+it.ID)
			}
			seen[it.ID] = true
			switch it.Source {
			case SourceFlatpak:
				if !ValidFlatpakID(it.Flatpak) {
					problems = append(problems, "invalid flatpak id for "+it.ID+": "+it.Flatpak)
				}
			case SourceLayer:
				if len(it.Packages) == 0 {
					problems = append(problems, "layer item without packages: "+it.ID)
				}
			default:
				problems = append(problems, "unknown source on "+it.ID+": "+string(it.Source))
			}
		}
	}
	return problems
}
