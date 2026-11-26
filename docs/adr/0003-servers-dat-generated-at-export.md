# ADR 0003: servers.dat is generated at export time from config/public.env

Status: accepted, 2026-11-26

## Context

The client pack pre-fills the Multiplayer server list so players join without typing a
hostname. That requires an NBT `servers.dat` containing the real public address and
display name. However, `packwiz` hashes every file under `pack/` into `index.toml`, and
template repositories must not commit a real server address into `pack/`.

## Decision

`scripts/pack-export.sh` copies `pack/` into a scratch directory under `.build/`, writes
`servers.dat` there with `scripts/make-servers-dat.py` (standard-library NBT writer and
`--verify` reader), refreshes, and exports from that scratch copy. `SERVER_NAME` and
`SERVER_PUBLIC_HOST` come from the committed `config/public.env` (with environment
variables overriding for one-off builds such as staging packs).

## Consequences

- `pack/` stays free of deployment-specific server entries and `packwiz refresh` on `pack/`
  is always a no-op.
- Deployers cloning or copying the template configure their public display name and
  hostname in one committed file (`config/public.env`) with no GitHub Actions secrets.
- CI publishes `dist/mmc3.mrpack` and `dist/mmc3.env` on `main` whenever
  `SERVER_PUBLIC_HOST` is non-empty, including the default placeholder
  `mc.example.com` (amended via `allow-placeholder-host-publish`), and skips
  publishing only when `SERVER_PUBLIC_HOST` is empty or unset. Deployers replace
  `mc.example.com` with their real hostname before sharing the pack with players,
  which changes `overrides/servers.dat` and triggers an automatic republish.
- Export scratch directories live under `.build/` (gitignored) rather than `/tmp` so
  Docker Desktop VMs can bind-mount them on macOS and Linux alike.
