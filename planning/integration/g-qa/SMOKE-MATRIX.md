# Smoke matrix — Hyprland + COSMIC

**Owner:** Model G (matrix + links). Manual execution is Director/integrator/operator.  
**Related:** `planning/qa/run-all.sh` (host packaging checks) · `MERGE-PLAYBOOK.md` (merge order).

This matrix ties **session-level** smokes from lanes E/F (when present) to a single day-of-integration checklist. If a linked file is missing, use the **fallback** column — do not skip the row silently.

---

## 0. Artifacts this matrix expects

| Artifact | Lane | Path |
|---|---|---|
| Host QA harness | G | `planning/qa/run-all.sh` |
| Pin / first-boot checklist | A | `planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md` |
| Hyprland session smoke | E | `planning/integration/e-hyprland/SESSION-SMOKE.md` |
| Hyprland keybind map | E | `planning/integration/e-hyprland/KEYBIND-MAP.md` |
| Hyprland autostart notes | E | `planning/integration/e-hyprland/AUTOSTART.md` |
| COSMIC session smoke | F | `planning/integration/f-cosmic/SESSION-SMOKE.md` |
| COSMIC greeter notes | F | `planning/integration/f-cosmic/GREETER.md` |
| COSMIC vendor inventory | F | `planning/integration/f-cosmic/VENDOR-INVENTORY.md` |
| Duress validate (packaging) | D | `planning/integration/d-duress/validate.sh` |
| Duress operator drill (optional deep) | D | `planning/integration/d-duress/DRILL.md` |
| Assistant tests | C | `cd apps/hyprwave-assistant && go test ./...` |

**When E/F not merged yet:** execute fallback rows in §3–4; re-run full linked docs after those lanes land.

---

## 1. Build matrix (before login)

| # | Variant | Command / action | Pass criteria | Log (P/F + notes) |
|---|---|---|---|---|
| B1 | Host QA | `bash planning/qa/run-all.sh` | RESULT OK; no unexpected FAIL | |
| B2 | Hyprland container | `just build` (or CI image) | Image builds; `bootc container lint` OK | |
| B3 | COSMIC container | `just build-cosmic` | Image builds; cosmic stage used | |
| B4 | Pins static | `bash planning/qa/run-all.sh --only pins-static` | No `/releases/latest` | |
| B5 | Themes | `bash planning/qa/run-all.sh --only themes` | All themes have required components | |
| B6 | No old stack | `bash planning/qa/run-all.sh --only no-wofi-swaybg` | No live wofi/swaybg | |
| B7 | Assistant unit | `bash planning/qa/run-all.sh --only assistant` | `go test` green if app present; else WARN noted | |
| B8 | Duress safety | `bash planning/qa/run-all.sh --only duress-safety` | No `*.sha256`; validate green if present | |
| B9 | Optional VM disk | `just build-qcow2` / cosmic equivalent | Disk produces; boots under QEMU | |

Image digests (fill in):

```
hyprwave:        _______________
hyprwave-cosmic: _______________
date (UTC):      _______________
tester:          _______________
```

---

## 2. First boot / greeter (both variants)

Use A’s checklist when present:  
`planning/integration/a-stabilize/FIRST-BOOT-CHECKLIST.md`

| # | Check | Hyprland | COSMIC | Pass criteria |
|---|---|---|---|---|
| F1 | Greeter appears | SDDM | cosmic-greeter (see F `GREETER.md` if present) | Login UI, not emergency shell |
| F2 | User session starts | Hyprland | cosmic-session | Desktop shell visible |
| F3 | Network (if expected) | nm / portal | same | Optional for offline smoke |
| F4 | No crash loop | journal user session | same | Stable ≥2 min |

COSMIC greeter details: prefer  
`planning/integration/f-cosmic/GREETER.md`  
when that file exists on the tree under test.

---

## 3. Hyprland session smoke

**Primary doc (when present):**  
`planning/integration/e-hyprland/SESSION-SMOKE.md`  
**Also:** `KEYBIND-MAP.md`, `AUTOSTART.md`

### 3.1 Linked execution

If `SESSION-SMOKE.md` exists:

```bash
# open and execute every checkbox; paste results below or attach log
test -f planning/integration/e-hyprland/SESSION-SMOKE.md && echo "use E doc"
```

Copy pass/fail from E’s list into the integration log. **Do not fork** requirements — E is source of truth for skel UX.

### 3.2 Fallback (E not merged — minimum 15 checks)

| # | Action | Pass criteria | P/F |
|---|---|---|---|
| H1 | Wallpaper shows (hyprpaper) | Not black/default unset | |
| H2 | Waybar visible | Modules render | |
| H3 | Super+Enter / terminal bind | Ghostty (or default term) opens | |
| H4 | Super+D or Super+Space | Walker opens | |
| H5 | Super+R runner | Walker runner prefix works | |
| H6 | Notifications | mako shows test notify | |
| H7 | File manager path | yazi via keybind/term | |
| H8 | Browser | Neonwolf launches | |
| H9 | FlatArcade | Launches in term or desktop entry | |
| H10 | Theme switch | `hyprwave-theme` or Super+Shift+T if bound | |
| H11 | Screenshot bind | File lands in expected dir | |
| H12 | Float/move basics | Windows move with binds | |
| H13 | Lock | hyprlock engages | |
| H14 | No wofi/swaybg processes | `ps` clean of removed stack | |
| H15 | Assistant (if installed) | Super+Shift+A or desktop entry | |

---

## 4. COSMIC session smoke

**Primary doc (when present):**  
`planning/integration/f-cosmic/SESSION-SMOKE.md`  
**Also:** `VENDOR-INVENTORY.md`, `GREETER.md`

### 4.1 Linked execution

If F’s `SESSION-SMOKE.md` exists, execute **all** of its items (≥12) and record results here or attach log.

### 4.2 Fallback (F not merged — minimum 12 checks)

| # | Action | Pass criteria | P/F |
|---|---|---|---|
| C1 | Session reaches desktop | Panel/dock visible | |
| C2 | Dock favorites | Includes Neonwolf, FlatArcade, Ghostty, Files, Settings (or documented intentional diff) | |
| C3 | Wallpaper | Hyprwave wallpaper path, not empty | |
| C4 | Theme accent | Synthwave-ish palette (pink/cyan/purple family) | |
| C5 | Ghostty | Launches from dock/launcher | |
| C6 | Neonwolf | Launches | |
| C7 | FlatArcade | Launches; COSMIC store not reintroduced as default app store | |
| C8 | CosmicFiles | Opens | |
| C9 | CosmicSettings | Opens | |
| C10 | App launcher | Finds Ghostty / Neonwolf | |
| C11 | Theme tool | `hyprwave-theme` applies cosmic config + wallpaper if supported | |
| C12 | No session crash | Stable ≥2 min; no greeter loop | |

---

## 5. Cross-cutting feature smokes (post-snippet)

| # | Feature | Command / action | Pass criteria | P/F |
|---|---|---|---|---|
| X1 | Assistant offline KB | `hyprwave-assistant` / CLI kb | Articles render offline | |
| X2 | Assistant dry-run | Update/install dry-run paths | No system mutation | |
| X3 | Duress assets on disk | `ls /usr/share/hyprwave/duress` | Templates + ENABLE.md present | |
| X4 | Duress PAM still off | Inspect `/etc/pam.d` | No default `pam_duress` enable | |
| X5 | Pins in running image | Check companion versions | Match `versions.env` | |

Deep duress: only on **disposable VM** per  
`planning/integration/d-duress/DRILL.md` (when present). Never on a machine with irreplaceable data.

---

## 6. Suggested half-day schedule

| Time | Activity |
|---|---|
| 0:00 | Merge order per MERGE-PLAYBOOK; host QA after A/C/D |
| 1:30 | `just build` + `just build-cosmic` |
| 2:30 | Hyprland VM: §2 + §3 (E doc preferred) |
| 3:30 | COSMIC VM: §2 + §4 (F doc preferred) |
| 4:30 | Cross-cutting §5; fix residuals or file issues |
| 5:00 | Tag `post-integration-*` if green |

---

## 7. Result template

```
Integration smoke log
date_utc:
main_sha:
hyprwave_digest:
cosmic_digest:
host_qa: PASS|FAIL
hyprland_session: PASS|FAIL|PARTIAL
cosmic_session: PASS|FAIL|PARTIAL
residuals:
  - 
signer/tester:
```

---

## 8. Policy

- Packaging FAIL on host harness **blocks** “integration complete” even if VMs look pretty.
- Missing E/F docs → fallback rows only; mark residual “link E/F SESSION-SMOKE when merged.”
- Model G updates this matrix when check IDs change; product UX criteria remain owned by E/F.
