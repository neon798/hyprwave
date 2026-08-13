# HANDOFF — Model E residuals (E-W1-004 freeze)

**From:** Model E (Hyprland skel)  
**Task:** E-W1-004  
**Date:** 2026-08-07  
**Branch:** `lane/e-hyprland` — ready for integrator merge

## Package / build.sh residuals

**None.** E does not request package list changes. Hyprland skel assumes the image
already ships (verified read-only historically): walker/elephant, waybar, mako,
hypridle/hyprlock/hyprpaper, hyprshot+grim/slurp, ghostty, yazi, neonwolf,
flatarcade, portals, fonts. Missing binary on a broken build → lane A / builder.

## Only open residual: Assistant bind uncomment (Model C)

Skel keeps Assistant **commented** (binary may be absent; **Super+A = FlatArcade**):

```bash
# bind = $mainMod SHIFT, A, exec, hyprwave-assistant
```

**After** `hyprwave-assistant` is on the image:

1. `command -v hyprwave-assistant`
2. Uncomment Super+SHIFT+A in `bindings.conf`
3. Move the row in `KEYBIND-MAP.md` from “Future / commented” → active
4. Add SESSION-SMOKE: Super+SHIFT+A launches Assistant
5. Optional: float windowrule if C publishes app-id

**Owner:** Model C + integrator. E does not enable a live bind without the binary.

## QA gate

Post-merge VM: run `SESSION-SMOKE.md` items **1–30** (minimum PASS).  
Map freeze: `KEYBIND-MAP.md` audited against `bindings.conf` (86 active + 1 commented).

## Out of scope

COSMIC (F) · Duress (D) · Assistant app (C) · `build.sh` (A) · theme pack wholesale
