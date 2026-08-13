# CURRENT_TASK

status: OPEN
task_id: F-W5-001
wave: 5
issued: 2026-08-13T04:05:00Z
poll: 2m
title: Post-merge vendor paths (F Wave 2–4 on main)

## Objective

COSMIC Waves 2–4 are on `main`. Re-run check-vendor-paths.sh.

```bash
git fetch origin && git checkout lane/f-cosmic
git merge origin/main || git rebase origin/main
git checkout origin/main -- planning/taskmaster/models/f/
```

## Exclusive paths

build_files/usr/share/cosmic/** disk_config/iso-cosmic.toml planning/integration/f-cosmic/** planning/taskmaster/models/f/**

## Done criteria

- [ ] `bash planning/integration/f-cosmic/check-vendor-paths.sh` exit 0
- [ ] `git push -u origin lane/f-cosmic`
