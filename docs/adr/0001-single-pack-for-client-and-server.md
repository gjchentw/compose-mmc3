# ADR 0001: A single curated packwiz pack feeds both client and server

Status: accepted, 2026-11-26

## Context

Modded Minecraft multiplayer breaks whenever the client and server drift on Minecraft,
Fabric loader, or mod versions. Two approaches were considered for running a Medieval MC 3
(MMC3)–style Fabric 1.21.1 server:

1. Wrapping the upstream 334-mod / 57 MB Luna Pixel Studios MMC3 modpack (where Modrinth
   froze at v18 with every mod marked `server: required` and 5,852 override files, while
   CurseForge ships separate client and server packs).
2. Maintaining a curated `packwiz` pack on Modrinth as the single source of truth for
   both players and the server, exporting one small `.mrpack`.

## Decision

The repository maintains one curated `packwiz` pack under `pack/` with 50 Modrinth mods
(40 `both`, 10 `client`), where every mod pins its exact `side` (`both` or `client`) and
SHA-512 hash. `packwiz modrinth export` produces one `dist/mmc3.mrpack` whose index marks
each file with client/server env flags. Players install that file in Modrinth App or
Prism Launcher; the server mounts the same file (`MODRINTH_MODPACK=/packs/mmc3.mrpack`)
and `itzg/minecraft-server` installs only entries whose server flag is not `unsupported`.
Client-only override files (`options.txt`, `servers.dat`) are excluded via
`MODRINTH_OVERRIDES_EXCLUSIONS`.

## Consequences

- Client and server mod sets stay locked by construction.
- The exported `.mrpack` stays a few kilobytes (only index + `options.txt` + `servers.dat`),
  so CI can publish it as a rolling commit on `main` without bloating git history.
- `scripts/pack-inspect.py` enforces the exact 50-mod side table so an unplanned
  dependency or misclassified client-only mod cannot slip onto the server.
- Only `pack/pack.toml` and a mod's `side` field (followed by `packwiz refresh`) may be
  hand-edited inside `pack/`.
