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
