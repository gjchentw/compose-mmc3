# Design

## Context

See `proposal.md` for motivation. Currently two scripts enforce the placeholder-host publish block:

1. `scripts/pack-publish.sh` sets `PACK_REQUIRE_REAL_HOST=1` for real CI runs and exits early (`skip`) whenever `SERVER_PUBLIC_HOST` is empty or equals `mc.example.com`.
2. `scripts/pack-export.sh` rejects `mc.example.com` whenever `PACK_REQUIRE_REAL_HOST` is non-empty, while always rejecting an empty `SERVER_PUBLIC_HOST` because `scripts/make-servers-dat.py` requires a non-empty `--host`.

Workflow descriptions (`.github/workflows/ci.yml`), `config/public.env` comments, `README.md`, `docs/upgrade.md`, and `docs/adr/0003-servers-dat-generated-at-export.md` also document the placeholder-host skip behavior.

## Goals / Non-Goals

**Goals:**
- Allow `scripts/pack-publish.sh` (both `--dry-run` and CI publish on `main`) and `scripts/pack-export.sh` to build and publish `dist/mmc3.mrpack` and `dist/mmc3.env` when `SERVER_PUBLIC_HOST=mc.example.com`.
- Preserve the guard that skips publishing (in `pack-publish.sh`) and fails export (in `pack-export.sh`) when `SERVER_PUBLIC_HOST` is empty or unset.
- Keep content-comparison idempotency intact: once `dist/mmc3.mrpack` and `dist/mmc3.env` are committed with `mc.example.com`, subsequent pushes to `main` that do not change `pack/` or `config/public.env` remain no-ops, and changing `SERVER_PUBLIC_HOST` to a real domain later will naturally change `overrides/servers.dat` and trigger an automatic republish.

**Non-Goals:**
- Changing the default `SERVER_PUBLIC_HOST=mc.example.com` in `config/public.env`.
- Removing `servers.dat` generation or allowing an empty server host entry.
- Changing the rolling-publish trigger rules (`push` to `main`, non-fork only, read-only default workflow token).

## Decisions

### Decision 1: Skip publishing only when `SERVER_PUBLIC_HOST` is empty, and remove `PACK_REQUIRE_REAL_HOST`

- **Choice**: In `scripts/pack-publish.sh`, change `if [ -z "$host" ] || [ "$host" = "mc.example.com" ]` to `if [ -z "$host" ]`, remove `export PACK_REQUIRE_REAL_HOST=1`, and remove the `PACK_REQUIRE_REAL_HOST` conditional block from `scripts/pack-export.sh`. Keep `[ -n "$host" ] || fail ...` in `scripts/pack-export.sh`.
- **Rationale**: The single check `[ -z "$host" ]` cleanly preserves an explicit opt-out (setting `SERVER_PUBLIC_HOST=` in `config/public.env`) while letting `mc.example.com` flow through the exact same export, inspection, byte-comparison, and commit path as any real hostname. Because `scripts/pack-publish.sh` compares archive members byte-for-byte, updating `config/public.env` from `mc.example.com` to a real hostname later alters `overrides/servers.dat` and triggers a clean republish automatically.
- **Alternatives considered**:
  - *Keep `PACK_REQUIRE_REAL_HOST` and toggle it via a repository variable or workflow input*: Rejected because it adds hidden GitHub settings that violate the repo's zero-secret / git-only configuration design (`public-server-info`) and still leaves `main` without `dist/` by default.
  - *Allow empty `SERVER_PUBLIC_HOST` and omit `servers.dat`*: Rejected because it breaks the `mrpack-distribution` contract requiring `overrides/servers.dat` with exactly one entry in every exported pack and weakens `pack-inspect.py` checks.

### Decision 2: Keep `config/public.env` set to `mc.example.com` and update comments/docs/ADR

- **Choice**: Retain `SERVER_PUBLIC_HOST=mc.example.com` in `config/public.env` (preserving `public-server-info`'s template placeholder requirement) and update comments and docs (`config/public.env`, `.github/workflows/ci.yml`, `README.md`, `docs/upgrade.md`, `docs/adr/0003-servers-dat-generated-at-export.md`) to state clearly that CI publishes `dist/mmc3.mrpack` even with `mc.example.com`, and deployers should replace `SERVER_PUBLIC_HOST` with their real hostname before sharing the pack with players.
- **Rationale**: Keeps `public-server-info` intact and ensures documentation, ADR 0003, and script behavior never drift out of sync.
- **Alternatives considered**:
  - *Leave ADR 0003 untouched and write a brand-new ADR 0005*: Rejected as unnecessary ceremony for a single consequence bullet; updating ADR 0003 with an explicit amendment note preserves historical context concisely.

## Risks / Trade-offs

- **Pre-filled dead server entry until customized**: Players who download `dist/mmc3.mrpack` before `SERVER_PUBLIC_HOST` is changed from `mc.example.com` will see a Multiplayer entry pointing to `mc.example.com` that does not resolve to a real server. → **Mitigation**: Document clearly in `config/public.env`, `README.md`, and `docs/upgrade.md` that deployers should replace `mc.example.com` with their real hostname before distributing the pack; once changed and merged to `main`, CI automatically republishes `dist/mmc3.mrpack` with the real `servers.dat`.
- **First merge to `main` triggers an automated publish commit**: Merging this change into `main` will immediately trigger CI to commit `dist/mmc3.mrpack` and `dist/mmc3.env` (approx. 8–10 KB total). → **Mitigation**: Expected and desired outcome; `scripts/pack-publish.sh --dry-run` verifies exact behavior on the PR before merge.
