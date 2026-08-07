# README blurb — Hyprwave Assistant (Model C)

Integrator: paste into README under companion apps / tools when wiring the image.

---

## Hyprwave Assistant

TUI for **system updates**, a **curated software installer**, and a short **knowledge base**.

```bash
hyprwave-assistant          # full TUI
hyprwave-assistant status   # bootc + flatpak summary
```

Or launch **Hyprwave Assistant** from the app menu (Ghostty).

| Tab | Purpose |
|-----|---------|
| Updater | `bootc status` / `bootc upgrade`, `flatpak update` with confirmations and reboot warnings |
| Installer | Curated Flatpak (and layer-note) catalog |
| Knowledge Base | Philosophy, updates, theming, variants, troubleshooting |
| About | Version and host tool detection |

Data files: `/usr/share/hyprwave/assistant/` (`catalog.toml`, `kb/*.md`).

**Not a FlatArcade replacement** — FlatArcade browses all of Flathub; the Assistant ships a short curated list plus OS update + docs.

Suggested keybind (optional): `Super+Shift+A` → `ghostty -e hyprwave-assistant`.

---

### Local dev (repo)

```bash
cd apps/hyprwave-assistant
go test ./...
go build -o /tmp/hyprwave-assistant .
HYPRWAVE_ASSISTANT_DATA=../../build_files/usr/share/hyprwave/assistant /tmp/hyprwave-assistant
```
