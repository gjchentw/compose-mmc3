# Proposal

## Why

After merging the initial MMC3 stack into `main`, CI skipped committing `dist/mmc3.mrpack` and `dist/mmc3.env` because `config/public.env` still carries the default placeholder address `mc.example.com`. Allowing CI to publish `dist/mmc3.mrpack` and `dist/mmc3.env` even when `SERVER_PUBLIC_HOST` is `mc.example.com` ensures a working modpack and version file are immediately available on `main` out of the box (for direct download, local checkout testing, and singleplayer/LAN use) before a deployer assigns a real public domain.

## What Changes

- Replace the `mrpack-distribution` requirement `Every change on main republishes the pack` with `Every change on main republishes the pack for non-empty hosts`, so CI publishes `dist/<pack>.mrpack` and `dist/<pack>.env` whenever `SERVER_PUBLIC_HOST` in `config/public.env` is non-empty (including the default placeholder `mc.example.com`) and skips publishing only when `SERVER_PUBLIC_HOST` is empty or unset.
- Remove the `mc.example.com` publish-skip check from `scripts/pack-publish.sh` and the `PACK_REQUIRE_REAL_HOST` guard from `scripts/pack-export.sh` while keeping the non-empty `SERVER_PUBLIC_HOST` validation intact.
- Update comments, workflow step descriptions, ADR 0003, and documentation (`config/public.env`, `.github/workflows/ci.yml`, `README.md`, `docs/upgrade.md`, `docs/adr/0003-servers-dat-generated-at-export.md`) to reflect that `mc.example.com` publishes `dist/mmc3.mrpack` and `dist/mmc3.env` (with a pre-filled entry pointing to `mc.example.com` until replaced).

### Out of Scope

- Changing `config/public.env` away from `mc.example.com` or setting a real production domain.
- Allowing an empty or missing `SERVER_PUBLIC_HOST` to publish or export a pack.
- Changing the mod list, Minecraft/Fabric/mod versions, `compose.yaml`, `compose.staging.yaml`, `pack/options.txt`, or the `0.0.0-dev` version contract in `pack/pack.toml`.
- Changing `public-server-info`, `compose-services`, or `game-requirements` specifications.

## Capabilities

### New Capabilities

### Modified Capabilities
- `mrpack-distribution`: Allow CI on `main` to publish `dist/<pack>.mrpack` and `dist/<pack>.env` when `SERVER_PUBLIC_HOST` is `mc.example.com`, skipping only when `SERVER_PUBLIC_HOST` is empty or unset.

## Impact

- **Specs**: `openspec/specs/mrpack-distribution/spec.md` (via delta spec in this change).
- **Scripts & CI**: `scripts/pack-publish.sh`, `scripts/pack-export.sh`, `.github/workflows/ci.yml`.
- **Config & Docs**: `config/public.env` (comment only), `README.md`, `docs/upgrade.md`, `docs/adr/0003-servers-dat-generated-at-export.md`.
- **Published artifacts on `main`**: Once merged to `main`, CI will commit `dist/mmc3.mrpack` and `dist/mmc3.env` automatically on push even while `SERVER_PUBLIC_HOST=mc.example.com`.
