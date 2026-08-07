# cosmic-greeter expectations (Hyprwave COSMIC)

**Task:** F-W1-001  
**Package:** `cosmic-greeter` (explicit install in `build.sh` `cosmic)` arm)  
**Unit:** `cosmic-greeter.service`  
**Alias:** `/etc/systemd/system/display-manager.service` → `cosmic-greeter.service`

---

## What we enable at build time

```bash
dnf5 install -y @cosmic-desktop-environment cosmic-greeter
systemctl enable cosmic-greeter.service
ln -sf /usr/lib/systemd/system/cosmic-greeter.service \
       /etc/systemd/system/display-manager.service
```

Goals:

1. Boot always has a graphical greeter (do not rely on comps group alone to pull greeter).
2. Generic `display-manager.service` matches the Hyprland variant’s SDDM pattern (one symlink story).
3. Session type offered is COSMIC (not Hyprland) on this image.

---

## Expected greeter UX

| Area | Expectation | Confidence |
|---|---|---|
| Boots to greeter | Yes — greeter is DM | High (systemd enable + symlink) |
| User list / password | Standard cosmic-greeter | High (upstream) |
| Session selection | COSMIC session entry present | High if `cosmic-session` installed |
| Hyprwave wallpaper on greeter | **Not guaranteed** | See known limits |
| Synthwave greeter theme (SDDM-parity) | **Not implemented** | Known limit |
| Branding (logo / accent) | Upstream COSMIC defaults unless greeter gains vendor keys later | Known limit |

---

## Wallpaper and theme — session vs greeter

| Layer | Mechanism | Hyprwave-branded? |
|---|---|---|
| **Session desktop** | `/usr/share/cosmic/com.system76.CosmicBackground/v1/all` → `/usr/share/backgrounds/hyprwave/default.png` | **Yes** (vendor default) |
| **Session colors** | `/usr/share/cosmic/com.system76.CosmicTheme.Dark{,.Builder}/` | **Yes** (`hyprwave-dark`) |
| **Greeter background** | cosmic-greeter’s own asset/config path (often separate from session CosmicBackground) | **Best-effort / often stock** |
| **Hyprland SDDM theme** | `build_files/usr/share/sddm/themes/hyprwave/` | **Hyprland variant only** — not used when DM is cosmic-greeter |

**Do not confuse** session wallpaper success with greeter wallpaper. Smoke item “wallpaper is Hyprwave” in `SESSION-SMOKE.md` is **after login**.

---

## Known limits

1. **No first-class cosmic-greeter theme pack in-tree**  
   Unlike SDDM’s `hyprwave` theme, we do not ship a parallel greeter skin under exclusive Model F paths. Upstream greeter styling may ignore session Dark vendor keys.

2. **Wallpaper path is session-oriented**  
   `CosmicBackground` vendor keys feed `cosmic-bg` inside a user session. Greeter may run as a greeter user/compositor with different XDG paths and may not read `/usr/share/cosmic/.../CosmicBackground`.

3. **Removing `cosmic-wallpapers`**  
   Declutter drops stock wallpaper packages. That cleans the *session* picker but can leave greeter on a solid color or a remaining system default if it depended on those assets. Prefer explicit greeter wallpaper config if/when upstream documents a stable vendor path.

4. **Multi-seat / autologin**  
   Not configured by Hyprwave. Anaconda/kickstart user creation (`disk_config`) does not set autologin; greeter remains the normal login gate.

5. **ISO vs qcow2**  
   ISO post-kickstart switches to `ghcr.io/neon798/hyprwave-cosmic:latest` (`iso-cosmic.toml`). Greeter behavior is a property of that image, not of Anaconda chrome.

6. **Accessibility / high-contrast greeter**  
   Vendor `is_high_contrast` is `false` for session Dark theme; greeter a11y follows upstream.

---

## Future improvements (out of F-W1-001 scope unless greeter gains a stable API)

- Vendor or drop-in wallpaper for greeter if System76 documents `/usr/share/cosmic-greeter/` (or similar) defaults.
- Optional accent color injection for greeter to match `#ff2d95` / `#15052e`.
- Document any greeter-specific RON keys next to this file when verified on a live F44 COSMIC build.

---

## Quick greeter checks (host/VM)

```bash
systemctl is-enabled cosmic-greeter.service
readlink -f /etc/systemd/system/display-manager.service
# Should end with cosmic-greeter.service

# After graphical boot (from TTY if needed):
loginctl
# Session type should be wayland; desktop COSMIC after login
```

**Pass criterion for greeter in this task:** greeter is the active DM and yields a COSMIC session. Wallpaper/theme parity with SDDM is **documented as a known limit**, not a silent failure.

---

## F-W1-002 — Branding vs greeter capabilities (reconfirm)

Cross-check with `THEME-COSMIC-MATRIX.md` path proofs (2026-08-07).

### What the greeter can show today

| Asset | Available in image? | Greeter consumes it? |
|---|---|---|
| `/usr/share/backgrounds/hyprwave/default.png` | Yes (staged in cosmic arm) | **Unknown / unlikely** — greeter has its own compositor user; does not reliably read session `CosmicBackground` |
| `/usr/share/cosmic/com.system76.CosmicTheme.Dark/**` | Yes | **Session only** after login (or if greeter explicitly loads cosmic-config — not verified on F44) |
| Theme pack wallpapers under `/usr/share/hyprwave/themes/*/wallpapers/` | Yes | **No** — switcher writes user session config only |
| SDDM `hyprwave` theme | Present in tree for Hyprland image | **Not active** when DM is `cosmic-greeter` |

### Expectation matrix (operator-facing)

| Surface | Hyprwave-branded? | Where documented |
|---|---|---|
| Login greeter chrome | Stock COSMIC / best-effort | This file (known limits) |
| Post-login wallpaper (first boot) | Yes — `default.png` via vendor Background | SESSION-SMOKE #5, #9 |
| Post-login wallpaper (after theme set) | Yes — theme store path | SESSION-SMOKE #26–#31 |
| Dock + Dark theme first boot | Yes — vendor AppList + Dark + Mode | VENDOR-INVENTORY / SESSION-SMOKE #10–#11 |

### Conclusion (F-W1-002)

No greeter wallpaper fix in this task: still **no stable in-tree cosmic-greeter theme API**. Session path proofs pass; greeter branding remains a **documented gap**, not a silent regression. Prefer investing in session `hyprwave-theme` + vendor Dark (already shipped) over speculative greeter hacks.

If upstream later documents e.g. `/usr/share/cosmic-greeter/` vendor keys, add a subsection here and a SESSION-SMOKE greeter visual item.

---

## Day-1 COSMIC vs Hyprland (support one-pager) — F-W1-003

Use this section when answering “what should first boot look like?” for each variant.
Model B may deep-link docs; this file stays the COSMIC greeter + day-1 expectation source.

| Concern | Hyprwave **Hyprland** | Hyprwave **COSMIC** |
|---|---|---|
| Display manager | SDDM (`sddm.service`) | **cosmic-greeter** (`display-manager` → greeter) |
| Login branding | SDDM theme `hyprwave` (synthwave) | **Stock / best-effort** greeter (not SDDM theme) |
| Session after login | Hyprland + waybar/walker/mako | COSMIC panel/dock/notifications |
| Default terminal | Ghostty | Ghostty (dock); `cosmic-term` installed but not promoted |
| Browser | Neonwolf | Neonwolf (same shared install) |
| App store story | FlatArcade | FlatArcade; **cosmic-store removed** |
| Wallpaper first boot | hyprpaper / theme store | Vendor `CosmicBackground` → `default.png` |
| Theme switcher | `hyprwave-theme` (Hyprland path) | `hyprwave-theme` (COSMIC path → `~/.config/cosmic`) |
| Installable ISO config | `disk_config/iso.toml` → `hyprwave:latest` | `disk_config/iso-cosmic.toml` → **`hyprwave-cosmic:latest`** |

### Day-1 support answers (COSMIC)

1. **“Greeter isn’t pink/synthwave”** — Expected. Greeter is not Hyprland SDDM. Session wallpaper/theme is branded after login. See known limits above.  
2. **“No COSMIC Store”** — Expected declutter; use FlatArcade from dock (`ghostty -e flatarcade`). See `DECLUTTER.md`.  
3. **“cosmic-term is installed but Ghostty is on the dock”** — Expected; session hard-dep vs default UX.  
4. **“Wrong desktop after ISO install”** — Verify kickstart switched to `ghcr.io/neon798/hyprwave-cosmic:latest`, not `hyprwave:latest`.  
5. **“Black screen after password”** — Fail session smoke #8; check `cosmic-session` / greeter logs — not a greeter wallpaper issue.

### Pass criterion (day-1 product)

Greeter logs the user into a COSMIC session with Hyprwave vendor chrome (wallpaper, dark theme, dock favorites). Greeter visual parity with Hyprland SDDM is **not** required for PASS.
