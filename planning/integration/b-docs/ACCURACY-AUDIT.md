# Accuracy audit (Model B)

**Tasks:** B-W1-001 … B-W1-005 (post-merge flip checklist)  
**Date:** 2026-08-07  
**Branch:** `lane/b-docs`  
**Scope:** Handbook claims vs tree on this branch + **read-only** lane tips

## Method

1. Read skel and theme store paths listed below.  
2. Reconcile `docs/keybinds.md` against `origin/lane/e-hyprland` KEYBIND-MAP + bindings.conf.  
3. Cross-link first-boot to A’s FIRST-BOOT-CHECKLIST and F greeter/session smoke.  
4. Grep operator docs for removed defaults (Wofi, swaybg, Thunar-as-default).  
5. Confirm Justfile recipe names used in INSTALL.  
6. Confirm greeter / DE split from `build_files/build.sh` case arms (main tree).  
7. Relative-link resolution across `docs/**`, INSTALL, README, CHANGELOG.

## Sources checked (file paths)

| Claim area | Source path(s) | Notes |
|------------|----------------|-------|
| Hyprland keybinds (endpoint) | `origin/lane/e-hyprland:build_files/etc/skel/.config/hypr/bindings.conf` | Read-only; Super+Shift+E exit, vim focus/move/resize, dwindle splitratio |
| Keybind machine map | `origin/lane/e-hyprland:planning/integration/e-hyprland/KEYBIND-MAP.md` | Full tables; conflicts section |
| Hyprland keybinds (main today) | `origin/main:…/bindings.conf` | Still Super+M exit / master ratio — handbook notes merge honesty |
| Walker prefixes / theme name | `build_files/etc/skel/.config/walker/config.toml` | |
| Autostart (elephant, waybar, mako, hyprpaper) | `origin/lane/e-hyprland:…/autostart.conf` + main skel | First-boot session chrome list |
| Theme pack list (11) | `build_files/usr/share/hyprwave/themes/*` | |
| Theme switcher CLI | `build_files/usr/bin/hyprwave-theme` | |
| Theme GUI desktop entry | `build_files/usr/share/applications/hyprwave-theme.desktop` | |
| Hyprland vs COSMIC packages / greeters | `build_files/build.sh` (`DE=hyprland\|cosmic`, SDDM, cosmic-greeter) | |
| COSMIC greeter expectations | `origin/lane/f-cosmic:planning/integration/f-cosmic/GREETER.md` | Session vs greeter branding |
| COSMIC session smoke | `origin/lane/f-cosmic:planning/integration/f-cosmic/SESSION-SMOKE.md` | Dock / apps / theme |
| COSMIC vendor inventory | `origin/lane/f-cosmic:…/VENDOR-INVENTORY.md` | Favorite order |
| First-boot operator checklist | `origin/lane/a-stabilize:planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` | Linked from docs/first-boot.md |
| Dual-variant smoke matrix | `origin/lane/g-qa:planning/integration/g-qa/SMOKE-MATRIX.md` | Cross-link only |
| ISO kickstart image refs | `disk_config/iso.toml`, `disk_config/iso-cosmic.toml` | |
| Just recipes | `Justfile` | build / build-cosmic / ISO / VM |
| Product overview | `README.md` (branch) | |
| Base image | `Containerfile` / `CLAUDE.md` (`ghcr.io/ublue-os/base-main`) | |
| External pin intent (pending merge) | `origin/lane/a-stabilize:build_files/versions.env` | Read-only |
| GHCR public? | **Not verified public** | INSTALL + FAQ + CHANGELOG contingency |

## Keybind reconciliation (B-W1-002)

| Handbook claim | Matches E bindings.conf? | Notes |
|----------------|--------------------------|-------|
| Super+D / Space / R / XF86Search → Walker | Yes | |
| Super+Return / T → Ghostty | Yes | |
| Super+E / B / A → Yazi / Neonwolf / FlatArcade | Yes | |
| Super+Shift+T → hyprwave-theme-gui | Yes | |
| Super+Shift+E → exit | Yes on E | **Not** Super+M; main still Super+M until merge |
| Super+H/J/K/L → movefocus | Yes on E | Main had setleftwideratio on H/L |
| Super+− / Shift+= → splitratio | Yes on E | Dwindle-safe |
| Super+Alt+arrows/hjkl → resize | Yes | |
| Super+Shift+L / P → hyprlock / hyprpicker | Yes | |
| Screenshot Super+S family | Yes | |
| Media XF86* | Yes | |
| COSMIC: Super binds N/A | Yes | Documented |

## First-boot sources (B-W1-002)

| Handbook section | Source |
|------------------|--------|
| Greeter split SDDM vs cosmic-greeter | build.sh + F GREETER.md |
| Hyprland chrome list | E autostart.conf |
| COSMIC dock order | F VENDOR-INVENTORY / VENDOR-FIXES |
| Tour table apps | bindings + README companions |
| Update / private GHCR | INSTALL + A FIRST-BOOT-CHECKLIST GHCR FAIL log |
| Duress off by default | security.md + task forbidden list |

## Removed-stack grep (operator docs)

```bash
rg -n 'Wofi|wofi|swaybg|Thunar' INSTALL.md CHANGELOG.md README.md docs/ \
  planning/integration/b-docs/*.md
```

**Expected:** only explicit “not used / replaced by” wording.

| Term | Allowed usage | Found as default? |
|------|---------------|-------------------|
| Wofi | Historical removal note | No |
| swaybg | Historical removal note | No |
| Thunar | Historical “not default” / Yazi | No |

## Claim checklist

| Claim | Verdict | Notes |
|-------|---------|-------|
| Launcher = Walker + elephant | OK | bindings + autostart + build.sh |
| Wallpaper = hyprpaper | OK | autostart; not swaybg |
| File manager = Yazi | OK | Super+E; not Thunar default |
| Browser = Neonwolf | OK | bindings + build.sh |
| App store = FlatArcade | OK | bindings + README |
| Terminal = Ghostty | OK | bindings |
| 11 themes | OK | 11 dirs under themes/ |
| Super+D/Space/R/Shift+T | OK | bindings.conf |
| Exit Super+Shift+E | OK as **E endpoint** | Merge note in keybinds.md |
| SDDM on hyprland image | OK | build.sh enable + conf |
| cosmic-greeter on cosmic | OK | build.sh + F GREETER.md |
| GHCR public | **Not claimed** | INSTALL + FAQ contingency |
| Duress default on | **Not claimed** | security.md off-by-default |
| Assistant shipped on main | **Not claimed** | CHANGELOG pending merge |
| Pins on main | Documented as **pending merge** from A | versions.env on a-stabilize |
| Wave-1 lanes shipped on GHCR | **Not claimed** | CHANGELOG table pending merge |

## Link check

Relative markdown links under handbook paths resolved with a local path walk.
Re-run after large doc moves (see B WORK_LOG for script one-liner).

Expected: 0 missing for in-repo targets. Links to `planning/integration/{a,e,f,g}-*`
may 404 on `main` until those lanes merge — handbook labels them “on lane”.

## Gaps left for other lanes / integrator

| Gap | Owner |
|-----|-------|
| GHCR visibility / public pull proof | A / ops |
| Merge pins + features to main | Integrator |
| Actual screenshot binaries | B Wave media / G QA |
| Assistant image hook | C + integrator |
| Duress enable (never default) | D + human security review |
| E bindings on published image | Integrator merge of `lane/e-hyprland` |
| F greeter docs on main tree | Integrator merge of `lane/f-cosmic` |

## Sign-off

Handbook language matches **lane product reality** for Walker / hyprpaper / Yazi /
themes / dual DE. Keybinds document E-lane ENDPOINT with explicit merge honesty.
Registry publicity and Wave-1 merge status remain deliberately cautious.


---

## B-W1-003 addendum (security / troubleshooting / screenshots)

**Date:** 2026-08-07  
**Read-only D sources:**

| Doc | Used for |
|-----|----------|
| `origin/lane/d-duress:build_files/duress/THREAT-MODEL.md` | Residual risks, non-goals (no LUKS, no forensics claim) |
| `origin/lane/d-duress:build_files/duress/ENABLE.md` | Off-by-default, sufficient PAM, no enable paste in handbook |
| `origin/lane/d-duress:planning/integration/d-duress/FAQ.md` | Condition table; upgrade drift; template severities |
| `origin/lane/d-duress:build_files/duress/README.md` | Assets-only packaging |

**Claim updates:**

| Claim | Verdict |
|-------|---------|
| Duress enabled by default | **Not claimed** — explicit assets-only / PAM-off |
| Duress replaces LUKS | **Not claimed** — security.md non-goals table |
| Dual-variant troubleshooting matrix | OK — greeter/launcher/theme both DEs |
| Screenshot rows have exact commands | OK — checklist H1–H11, C1–C5, M1–M2 |
| Compositor-less host blocker | Documented |
| GHCR public | Still **not claimed** |

**New handbook files:** `docs/screenshots.md` → checklist + `docs/assets/` reserved.


---

## Pre-merge handbook freeze (B-W1-004)

| Field | Value |
|-------|--------|
| Freeze date (UTC) | 2026-08-07 |
| origin/main tip at freeze | `371ea34` |
| Lane | `lane/b-docs` |
| Intent | User handbook ready for integrator serial merge; CHANGELOG has post-merge template |

### Freeze claims

| Area | State |
|------|--------|
| Stock desktop (Walker, hyprpaper, Yazi, dual DE, 11 themes) | Documented; base on main `8a623a2` + lane polish pending |
| A–G lane table | Final honesty table in CHANGELOG Unreleased |
| Post-merge template | CHANGELOG subsection for integrator flip-to-Released |
| Architecture | bootc + dual DE + theme store + Assistant/duress **boundaries** |
| Contributor refresh | docs/contributor-notes.md post-merge checklist + PROTOCOL link |
| Duress default on | **Not claimed** |
| Features only on lanes claimed as on main GHCR | **Not claimed** |
| Screenshot binaries | Still TODO (ops ready) |

### After merge

Re-run link check, refresh ACCURACY-AUDIT with **merge commit**, execute CHANGELOG
Post-merge template checkboxes, drop obsolete “pending merge” banners.


---

## Post-merge pass (B-W1-005 prep)

| Field | Value |
|-------|--------|
| Prepared | 2026-08-07 |
| Checklist | `planning/integration/b-docs/POST-MERGE-DOC-FLIP.md` |
| Status | **Not executed** — product A–G still unmerged on main at authoring time |
| When to run | After integrator serial merge (or partial merge); then fill claims below |

### Post-merge pass log (fill when run)

| Check | Result |
|-------|--------|
| main tip | `77755f1` (docs flip on top of this; merge tag `post-integration-20260807`) |
| Link check | checked=263 missing=0 (2026-08-13 flip) |
| Keybinds match skel | Super+Shift+E exit; Super+Shift+A assistant; Super+Shift+T themes |
| Duress still off-by-default in docs | **Yes** |
| GHCR public claim avoided unless verified | **Yes** — GHCR `:latest` not claimed as this tip |
| CHANGELOG dated release section | `## [2026-08-13] — Wave 1 integration` |
| Pending-merge banners reduced accurately | Handbook flipped; historical planning docs left as-is |

Pass executed 2026-08-13 (integrator). Product A–G on `main`. T8 image/VM/GHCR still open.

---

## B-W2-001 addendum (2026-08-13)

| Check | Result |
|-------|--------|
| Super+Shift+A | `build_files/etc/skel/.config/hypr/bindings.conf` → `ghostty -e hyprwave-assistant`; documented in `docs/keybinds.md` Essentials |
| Assistant companion | README table + default stack + optional extras; desktop entry `hyprwave-assistant.desktop` |
| COSMIC dock | README matches `build_files/usr/share/cosmic/com.system76.CosmicAppList/v1/favorites` (Neonwolf, FlatArcade, Ghostty, Cosmic Files, Hyprwave Themes, Cosmic Settings) |
| ISSUES B-5 | Closed: assistant hooked; duress packaged OFF |
| Duress default on | **Not claimed** (security.md + faq) |
| GHCR public | **Not claimed** |
| Screenshots | Still TODO (B-7) |
| Sweep leftover “upcoming Assistant” | README / faq / security rewritten |

---

## B-W2-002 addendum (2026-08-13)

| Check | Result |
|-------|--------|
| IMAGE_NAME default | Justfile `env("IMAGE_NAME", "image-template")` — **not edited** |
| INSTALL Path C | Documents default `image-template`, override `just build hyprwave latest` / `IMAGE_NAME=hyprwave`, CI uses repo name |
| contributor-notes | Same IMAGE_NAME note under Building and validating |
| ISSUES B-6 | **Closed** (docs-only) |
| screenshot-checklist | Hygiene only: IMAGE_NAME + DE mix-up blockers; C2 dock favorites; H8 skel bind; all Status still **TODO** |
| Screenshot binaries | **None added** (B-7 open) |
| Duress default on | **Not claimed** |
| GHCR public | **Not claimed** |
| Justfile | **Untouched** |

---

## B-W3-001 addendum (2026-08-13)

| Check | Result |
|-------|--------|
| Anonymous GHCR public claim | **Avoided** — INSTALL says private / 403; podman pull framed as diagnostic |
| Primary path | Local build Path C (`just build hyprwave latest` → `localhost/hyprwave:latest`) |
| Path A | Requires public GHCR **or** `podman login` |
| first-boot.md | How-you-got-image table; localhost refs; greeters SDDM vs cosmic-greeter |
| Dual-variant greeters | Unchanged accuracy (SDDM / cosmic-greeter) |
| Screenshot binaries | **None** (B-7 still open) |
| Duress default on | **Not claimed** (first-boot still off by default) |
| IMAGE_NAME | Path C still documents image-template default |

---

## B-W4-001 addendum (2026-08-13)

Merge-prep: CHANGELOG Unreleased records W2–W3 handbook deltas (Assistant Super+Shift+A, IMAGE_NAME, local-build primary / GHCR 403). ISSUES B-5/B-6 closed, B-7 open. **No public-GHCR claim.** No screenshot binaries.

---

## B-W5-001 addendum (2026-08-13)

Post-merge verify on tip after B Waves 2–4 land on main: relative link walk **checked=150 missing=0**. Super+Shift+A present in `docs/keybinds.md` Essentials (`ghostty -e hyprwave-assistant`). README lists Assistant as shipped. **No GHCR-public claim**; **duress still off by default**.

