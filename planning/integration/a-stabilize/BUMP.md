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

   # full rebuild when you can afford it
   just build hyprwave latest
   ```

5. **Commit** with a message that names the apps and tags, e.g.

   ```
   Pin companion apps: yazi vX, neonwolf vY, flatarcade vZ
   ```

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
