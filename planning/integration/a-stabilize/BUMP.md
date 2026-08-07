# Bumping pinned companion app versions

External binaries (Yazi, Neonwolf, FlatArcade) are **not** pulled from
GitHub `/releases/latest`. Pins live in:

```
build_files/versions.env
```

`build_files/build.sh` sources that file as `/ctx/versions.env` and verifies
each download with `sha256sum -c` before installing.

## When to bump

- Security fix or important feature in an upstream release
- A full image rebuild after a pin goes stale and CI/users report breakage
- Prefer deliberate bumps over tracking every upstream release

## How to bump (checklist)

1. **Pick the new tag** from the project’s GitHub Releases page (not the
   `latest` redirect if you can help it — copy the concrete tag name).

   | App        | Releases                                            |
   |------------|-----------------------------------------------------|
   | Yazi       | https://github.com/sxyazi/yazi/releases             |
   | Neonwolf   | https://github.com/neon798/neonwolf/releases        |
   | FlatArcade | https://github.com/neon798/flatarcade/releases      |

2. **Edit only `build_files/versions.env`** (and nothing else unless asset
   names changed):
   - Set `*_VERSION` to the new tag (include the leading `v` if the tag has it).
   - Confirm `*_URL` / `*_SVG_URL` still match the release asset names.
   - Recompute and set each `*_SHA256`.

3. **Recompute sha256** for each asset:

   ```bash
   # Example: Yazi
   curl -fsSL -o /tmp/asset \
     "https://github.com/sxyazi/yazi/releases/download/vNEW/yazi-x86_64-unknown-linux-gnu.zip"
   sha256sum /tmp/asset
   ```

   Repeat for Neonwolf AppImage, FlatArcade binary, and FlatArcade SVG.

4. **Sanity-check locally** (optional full image build):

   ```bash
   # syntax / static
   just lint
   just check
   grep -n 'releases/latest' build_files/build.sh   # must stay empty

   # HEAD-check versioned URLs (no full download)
   bash planning/integration/a-stabilize/scripts/verify-pins.sh

   # full rebuild when you can afford it
   just build hyprwave latest
   ```

5. **Commit** with a message that names the apps and tags, e.g.

   ```
   Pin companion apps: yazi vX, neonwolf vY, flatarcade vZ
   ```

## CI guards (Wave 2)

`.github/workflows/build.yml` job **`pin_guards`** fails the pipeline if:

- `build_files/build.sh` contains `releases/latest`
- any `build_files/**/*.sh` fails `bash -n`
- required keys are missing from `versions.env`
- `verify-pins.sh` cannot HEAD the versioned URLs

After a bump, open a PR (or push a branch that runs the workflow) and confirm
`pin_guards` is green before relying on a full image build.

## Rules

- **Never** reintroduce `/releases/latest` in `build.sh`.
- **Always** ship a matching sha256; a wrong hash must fail the image build.
- If an upstream renames an asset, update the URL in `versions.env` (and
  only touch `build.sh` if the install steps themselves change).
- Do not pin via mutable CDN caches; versioned GitHub release URLs only.

## Current pins (at lane A land)

| Variable focus     | Source of truth        |
|--------------------|------------------------|
| `YAZI_*`           | `build_files/versions.env` |
| `NEONWOLF_*`       | `build_files/versions.env` |
| `FLATARCADE_*`     | `build_files/versions.env` |

Read the file itself for the live values; this doc intentionally does not
duplicate tag numbers so it cannot drift.

---

## Worked example: bump FlatArcade end-to-end

This walkthrough uses FlatArcade as the single component being bumped.
Commands are copy-pasteable; substitute the real **new** tag when one exists.

### 0. Baseline

```bash
git checkout lane/a-stabilize
grep '^FLATARCADE_' build_files/versions.env
bash planning/integration/a-stabilize/scripts/verify-pins.sh   # expect exit 0
```

### 1. Discover the target release

Open https://github.com/neon798/flatarcade/releases and copy the tag
(e.g. `v0.1.0` — use a newer tag when bumping for real). Confirm assets:

- `flatarcade` (binary)
- `flatarcade.svg` (icon)

### 2. Download and hash

```bash
NEW=v0.1.0   # <-- replace with the tag you are bumping TO
curl -fsSL -o /tmp/flatarcade \
  "https://github.com/neon798/flatarcade/releases/download/${NEW}/flatarcade"
curl -fsSL -o /tmp/flatarcade.svg \
  "https://github.com/neon798/flatarcade/releases/download/${NEW}/flatarcade.svg"
sha256sum /tmp/flatarcade /tmp/flatarcade.svg
```

Example output shape (hashes must match whatever you just downloaded):

```
f0e0c097011077adec06f226daad5e60cdc7de1eead80b7be07297fbb3bd2096  /tmp/flatarcade
6f9a1def99179f9a93f91b5454e00a810cf9ed74a4fbfa077b941b74ac2ef84b  /tmp/flatarcade.svg
```

### 3. Edit `build_files/versions.env` only

```bash
# Only these four lines (URL expands from VERSION via ${FLATARCADE_VERSION}):
FLATARCADE_VERSION=v0.1.0
FLATARCADE_URL="https://github.com/neon798/flatarcade/releases/download/${FLATARCADE_VERSION}/flatarcade"
FLATARCADE_SHA256=<paste from sha256sum>
FLATARCADE_SVG_URL="https://github.com/neon798/flatarcade/releases/download/${FLATARCADE_VERSION}/flatarcade.svg"
FLATARCADE_SVG_SHA256=<paste from sha256sum>
```

Do **not** change `build.sh` unless asset **names** changed (rare).

### 4. Validate before commit

```bash
grep -n 'releases/latest' build_files/build.sh && exit 1 || echo OK
bash planning/integration/a-stabilize/scripts/verify-pins.sh
# Stronger (downloads + checks digests; use --light to skip huge Neonwolf):
bash planning/integration/a-stabilize/scripts/verify-pins.sh --checksum --light
```

### 5. Commit and push

```bash
git add build_files/versions.env
git commit -m "Pin FlatArcade ${NEW}"
git push -u origin lane/a-stabilize
# After merge to main: pin_guards + dual image build must stay green
```

### 6. Rollback if the bump breaks the image

1. `git revert <bump-commit>` (or restore previous `FLATARCADE_*` lines from `git show HEAD~1:build_files/versions.env`).
2. Re-run `verify-pins.sh` and `pin_guards` locally (or push and let CI run).
3. Rebuild / re-publish so GHCR `latest` no longer embeds the bad binary.
4. See `RELEASE.md` § Rollback for image-level rollback (`bootc` consumers on a dated tag).
