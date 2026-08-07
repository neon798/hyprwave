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
