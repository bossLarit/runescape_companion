# Current Tasks

## 1. Fix version not updating on release

- [x] Diagnose root cause: CI workflows never pass tag version to `flutter build`
- [x] `release.yml` — extract version from git tag, pass `--build-name`/`--build-number`
- [x] `qa.yml` — same fix for tag pushes; fallback to pubspec for branch pushes
- [x] `dev.yml` — extract version from pubspec, pass `--build-name`/`--build-number`

### Review

- **Root cause:** `flutter build` used hardcoded `pubspec.yaml` version; tag version was ignored
- **Fix:** All 3 workflows now extract the version and pass `--build-name`/`--build-number` overrides
- **Prod (`release.yml`):** Version comes from git tag (e.g. `v1.2.0` → `1.2.0`)
- **QA (`qa.yml`):** Version from tag if tag push, else from pubspec
- **Dev (`dev.yml`):** Version from pubspec
- **Build number:** All use `github.run_number` for unique incrementing build numbers
- **No app code changes needed** — `package_info_plus` already reads the baked-in version correctly

## 2. Idle Adventurer Mini-Game

- [x] Domain models (Player, Monster, Gear, GameState)
- [x] Game data (monsters, gear tiers, XP table)
- [x] Game engine (combat loop, damage calc, leveling)
- [x] Riverpod provider + JSON persistence
- [x] Game screen UI (combat area, stats, shop)
- [x] Wire into app navigation (sidebar)
- [x] Verify flutter analyze + test in-app
