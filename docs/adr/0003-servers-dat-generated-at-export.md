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
- CI skips publishing on `main` while `SERVER_PUBLIC_HOST` remains the placeholder
  `mc.example.com`, ensuring published packs only ever point at a real server.
- Export scratch directories live under `.build/` (gitignored) rather than `/tmp` so
  Docker Desktop VMs can bind-mount them on macOS and Linux alike.
