// Package kb loads Knowledge Base markdown articles from disk.
package kb

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/sahilm/fuzzy"
)

// Article is one markdown KB entry.
type Article struct {
	ID      string // filename without .md
	Title   string
	Path    string
	Body    string
	Preview string // first non-empty line after title
}

// Store holds all loaded articles.
type Store struct {
	Articles []Article
	Dir      string
}

// LoadDir reads all *.md files from dir (non-recursive).
func LoadDir(dir string) (*Store, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, fmt.Errorf("read kb dir: %w", err)
	}
	s := &Store{Dir: dir}
	for _, e := range entries {
		if e.IsDir() || !strings.HasSuffix(e.Name(), ".md") {
			continue
		}
		path := filepath.Join(dir, e.Name())
		data, err := os.ReadFile(path)
		if err != nil {
			return nil, err
		}
		body := string(data)
		id := strings.TrimSuffix(e.Name(), ".md")
		title, preview := parseTitlePreview(body, id)
		s.Articles = append(s.Articles, Article{
			ID:      id,
			Title:   title,
			Path:    path,
			Body:    body,
			Preview: preview,
		})
	}
	sort.Slice(s.Articles, func(i, j int) bool {
		return s.Articles[i].Title < s.Articles[j].Title
	})
	return s, nil
}

// LoadFromDirs tries each path that ends in kb/ or contains kb subdir.
func LoadFromDirs(dirs []string) (*Store, error) {
	var errs []string
	for _, d := range dirs {
		// accept either .../assistant or .../assistant/kb
		candidates := []string{
			filepath.Join(d, "kb"),
			d,
		}
		for _, c := range candidates {
			st, err := LoadDir(c)
			if err == nil && len(st.Articles) > 0 {
				return st, nil
			}
			if err != nil {
				errs = append(errs, fmt.Sprintf("%s: %v", c, err))
			}
		}
	}
	return nil, fmt.Errorf("kb not found:\n  %s", strings.Join(errs, "\n  "))
}

func parseTitlePreview(body, fallbackID string) (title, preview string) {
	title = strings.ReplaceAll(fallbackID, "-", " ")
	if len(title) > 0 {
		title = strings.ToUpper(title[:1]) + title[1:]
	}
	lines := strings.Split(body, "\n")
	for _, line := range lines {
		t := strings.TrimSpace(line)
		if t == "" {
			continue
		}
		if strings.HasPrefix(t, "# ") {
			title = strings.TrimSpace(strings.TrimPrefix(t, "# "))
			continue
		}
		if strings.HasPrefix(t, "##") {
			continue
		}
		if preview == "" && !strings.HasPrefix(t, "#") {
			preview = t
			if len(preview) > 100 {
				preview = preview[:97] + "..."
			}
			break
		}
	}
	return title, preview
}

// Search returns articles matching query (fuzzy on title + body + id).
// Empty query returns all articles in store order.
func (s *Store) Search(query string) []Article {
	if s == nil || len(s.Articles) == 0 {
		return nil
	}
	q := strings.TrimSpace(query)
	if q == "" {
		out := make([]Article, len(s.Articles))
		copy(out, s.Articles)
		return out
	}
	targets := make([]string, len(s.Articles))
	for i, a := range s.Articles {
		targets[i] = a.Title + " " + a.ID + " " + a.Preview + " " + a.Body
	}
	matches := fuzzy.Find(q, targets)
	out := make([]Article, 0, len(matches))
	for _, m := range matches {
		out = append(out, s.Articles[m.Index])
	}
	return out
}

// Get by ID.
func (s *Store) Get(id string) *Article {
	if s == nil {
		return nil
	}
	for i := range s.Articles {
		if s.Articles[i].ID == id {
			return &s.Articles[i]
		}
	}
	return nil
}
