# Post-merge handbook flip checklist

**Audience:** integrator, or Model B after Wave-1 lanes land on `main`.  
**Goal:** change handbook language from **“pending merge / lane-only”** to **“on main / on the published image”** without inventing product facts.

| Field | Value |
|-------|--------|
| Freeze baseline | B-W1-004 handbook freeze on `lane/b-docs` |
| Product truth | **What is on the merge commit + booted image**, not what a lane *intended* |
| Companion doc | [CHANGELOG.md](../../../CHANGELOG.md) Unreleased → **Post-merge template** |
| Protocol | [planning/taskmaster/PROTOCOL.md](../../taskmaster/PROTOCOL.md) |

Do **not** run this checklist until the relevant product commits are actually on
`main` (or on the image tip you are documenting). Partial merges: flip **only**
rows that landed.

---

## 0. Preconditions

- [ ] Serial merge (or documented subset) complete per G `MERGE-PLAYBOOK` when present  
- [ ] `git fetch origin main && git rev-parse --short origin/main` recorded: `________`  
- [ ] Optional: image built / GHCR tag published: `________`  
- [ ] Optional: dual-variant smoke noted (pass/fail/skip): `________`  
- [ ] Working tree for docs: `lane/b-docs` rebased/merged onto new main, or edit on main if integrator owns docs in the merge PR  

**Honesty rules (never break):**

1. Do not claim a feature is on GHCR `:latest` unless that tag was rebuilt from the merge.  
2. Do not claim **GHCR is public** unless anonymous `podman pull` was verified this pass.  
3. Do not claim **duress is on by default** — assets may ship; PAM stays off unless an admin enables it.  
4. Do not invent keybinds not in `build_files/etc/skel/.config/hypr/bindings.conf` on the merge tip.  
5. Skel defaults apply to **new users only** — say so when defaults changed.  
6. Assistant: only “installed” if the binary/package is on the image; otherwise keep “optional / not hooked”.

---

## 1. Re-read product sources (merge tip)

Run on the **post-merge** tree (main tip or image checkout):

```bash
git fetch origin main
git rev-parse --short origin/main

# Keybinds ENDPOINT
sed -n '1,120p' build_files/etc/skel/.config/hypr/bindings.conf

# Autostart / DE
rg -n 'exec-once|walker|hyprpaper|waybar' build_files/etc/skel/.config/hypr/autostart.conf

# Greeters / DE case
rg -n 'sddm|cosmic-greeter|DE=' build_files/build.sh | head -40

# Pins (if A merged)
test -f build_files/versions.env && cat build_files/versions.env || echo 'no versions.env'

# Duress assets present? PAM still off?
ls build_files/duress 2>/dev/null || ls /usr/share/hyprwave/duress 2>/dev/null || echo 'no duress tree in checkout'
rg -n 'pam_duress' build_files/ 2>/dev/null || true

# Assistant hooked?
rg -n 'hyprwave-assistant' build_files/ Containerfile 2>/dev/null || echo 'assistant not referenced in image build'
```

Fill:

| Source | Observed (short) |
|--------|------------------|
| Exit keybind | Super+____ |
| Walker/hyprpaper defaults | yes/no |
| `versions.env` | present / absent |
| Duress assets on image path | yes/no; PAM still off? |
| Assistant in image | yes/no |

---

## 2. CHANGELOG — flip to Released

File: **[CHANGELOG.md](../../../CHANGELOG.md)**

### 2.1 Create dated section

- [ ] Copy **Post-merge template** from Unreleased into `## [YYYY-MM-DD] — Wave 1 integration`  
- [ ] Check only lanes that **actually merged** (A–G checkboxes)  
- [ ] Fill image refs / digests / Cosign **only if known**  

### 2.2 Unreleased cleanup

- [ ] Remove or rewrite **Status (honest merge state — pre-merge freeze)** so it no longer says all of A–G are pending if they landed  
- [ ] Update or archive **Wave-1 lane deliverables** table:  
  - Merged rows → “Shipped on main as of YYYY-MM-DD” or delete and rely on dated section  
  - Unmerged rows → remain under Unreleased as **still pending**  
- [ ] Keep **Post-merge template** (or replace with a pointer to this file) for future waves  
- [ ] Known gaps: drop items that are fixed; keep GHCR private if still 403  

### 2.3 Pointer (optional but recommended)

Under Post-merge template, ensure a line like:

```markdown
Full doc flip steps: [planning/integration/b-docs/POST-MERGE-DOC-FLIP.md](planning/integration/b-docs/POST-MERGE-DOC-FLIP.md)
```

---

## 3. File-by-file handbook edits

Edit only if the underlying product claim changed on main.

| File | Sections / search terms | Flip action when product landed |
|------|-------------------------|----------------------------------|
| [docs/keybinds.md](../../../docs/keybinds.md) | “Merge honesty”, Super+M, “until E merge”, `lane/e-hyprland` | If E on main: document live binds; remove obsolete Super+M-as-current warnings |
| [docs/first-boot.md](../../../docs/first-boot.md) | “on lane”, A FIRST-BOOT path, F greeter path | Prefer in-tree `planning/integration/…` links if files merged; else keep path notes |
| [docs/cosmic.md](../../../docs/cosmic.md) | F GREETER/SESSION-SMOKE “on lane” | Point at paths on main if present; keep greeter stock-face limit if still true |
| [docs/security.md](../../../docs/security.md) | “pending merge”, D-lane paths | If D assets on image: say packaging may be present; **PAM off by default** unchanged |
| [docs/architecture.md](../../../docs/architecture.md) | “Optional / lane packaging”, pending | Assistant/duress: “shipped assets / optional” vs still pending; never stock-on for duress |
| [docs/troubleshooting.md](../../../docs/troubleshooting.md) | E-lane exit bind note | Align exit bind with post-merge skel |
| [docs/contributor-notes.md](../../../docs/contributor-notes.md) | “Until merge”, refresh checklist | Point contributors at **this file** for post-merge; keep PROTOCOL |
| [INSTALL.md](../../../INSTALL.md) | “after E-lane merge”, F greeter lane notes | Soften to current greeter/bind reality; keep private GHCR if unproven |
| [README.md](../../../README.md) | Upcoming / pending | Only list Assistant/duress as shipped if true |
| [docs/faq.md](../../../docs/faq.md) | duress / assistant | Align with security; no default-on |
| [docs/README.md](../../../docs/README.md) | index blurbs | Drop “pending merge” from index if obsolete |
| [docs/screenshots.md](../../../docs/screenshots.md) | — | No flip required unless assets committed |
| [docs/theming.md](../../../docs/theming.md) / updating / etc. | — | Touch only if product behavior changed |

### Search commands (find remaining “pending” noise)

```bash
rg -n 'pending merge|lane/e-hyprland|lane/f-cosmic|lane/a-stabilize|lane/d-duress|lane/c-assistant|until merge|on lane' \
  INSTALL.md CHANGELOG.md README.md docs/ planning/integration/b-docs/
```

Review each hit: **keep** if still accurate; **edit** if the lane has landed.

---

## 4. Integration / audit paths

| Path | Action |
|------|--------|
| [ACCURACY-AUDIT.md](ACCURACY-AUDIT.md) | New **Post-merge pass** section: main tip, date, link check count, claims re-verified |
| [screenshot-checklist.md](screenshot-checklist.md) | Optional: mark CAPTURED if binaries added |
| [ISSUES.md](ISSUES.md) | Close or carry product gaps found during flip |
| This file | Check boxes; leave history for the next wave |

---

## 5. Validation

```bash
# Relative links (skip fenced code samples)
python3 - <<'PY'
import re
from pathlib import Path
def strip_fences(t): return re.sub(r"```.*?```", "", t, flags=re.S)
files=[]
for r in [Path("INSTALL.md"),Path("CHANGELOG.md"),Path("README.md"),Path("docs"),Path("planning/integration/b-docs")]:
    files += [r] if r.is_file() else list(r.rglob("*.md"))
link_re=re.compile(r"\[([^\]]*)\]\(([^)]+)\)")
miss=[]; n=0
for f in files:
    for m in link_re.finditer(strip_fences(f.read_text(errors="replace"))):
        u=m.group(2).strip()
        if u.startswith(("http://","https://","mailto:","#")): continue
        p=u.split("#")[0]
        if not p: continue
        n+=1
        if not (f.parent/p).resolve().exists(): miss.append((str(f),u))
print(f"checked={n} missing={len(miss)}")
for x in miss: print("MISSING", x)
PY

# Forbidden claim greps
rg -n 'duress.*(enabled by default|on by default)|enabled by default.*duress' INSTALL.md CHANGELOG.md README.md docs/ -i || true
rg -n 'GHCR is public|publicly available on GHCR' INSTALL.md CHANGELOG.md README.md docs/ -i || true
rg -n 'default launcher is [Ww]ofi|uses swaybg|Thunar as default' INSTALL.md CHANGELOG.md README.md docs/ || true
```

- [ ] Link check: 0 missing (or only intentional external)  
- [ ] No duress-on-by-default  
- [ ] No unverified GHCR-public claim  
- [ ] No Wofi/swaybg/Thunar-as-default  

---

## 6. Done criteria for the flip pass

- [ ] CHANGELOG has dated Wave-1 section reflecting **merged** reality only  
- [ ] Handbook “pending merge” language matches **remaining** unmerged work  
- [ ] Keybinds/security/architecture match skel + packaging on main tip  
- [ ] ACCURACY-AUDIT post-merge section filled  
- [ ] Commits pushed (docs PR or `lane/b-docs` → main as directed)  

**Out of scope for docs flip:** enabling duress PAM, making GHCR public, capturing screenshot binaries (unless someone already added files under `docs/assets/`).

---

## Related

- [CHANGELOG.md](../../../CHANGELOG.md) — Unreleased table + Post-merge template  
- [docs/contributor-notes.md](../../../docs/contributor-notes.md) — refresh overview  
- [docs/architecture.md](../../../docs/architecture.md) — packaging boundaries  
- [docs/security.md](../../../docs/security.md) — duress off by default  
