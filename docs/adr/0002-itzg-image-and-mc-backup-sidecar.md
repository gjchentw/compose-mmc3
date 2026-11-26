# ADR 0002: itzg images pinned by digest, a backup sidecar, and a packwiz image built from source

Status: accepted, 2026-11-26

## Context

Running a modded Minecraft server under Docker Compose requires choosing between a custom
JDK Dockerfile, bare JAR management scripts, or the community `itzg/minecraft-server`
image. Backups can run from host cron or from a companion container. `packwiz` has no
official container image, and the deployment host should require only Docker and bash.

## Decision

- Server: `docker.io/itzg/minecraft-server`, pinned by tag and multi-arch index digest
  (`linux/amd64` and `linux/arm64`). It installs Modrinth `.mrpack` files, honors side
  markers, translates SIGTERM into a graceful RCON stop (`stop_grace_period: 2m`), and
  ships `mc-health`, `mc-monitor`, and `rcon-cli`.
- Backups: `docker.io/itzg/mc-backup` as a Compose sidecar waiting on `minecraft`
  `service_healthy`, coordinating `save-off` / `save-all flush` / `save-on` over internal
  RCON, writing tar archives to `./backups`, excluding secret-bearing files
  (`server.properties`, `.rcon-cli.env`, `.rcon-cli.yaml`), and pruning only top-level
  archives so `backups/keep/` is preserved.
- Tooling: `tools/packwiz/Dockerfile` compiles `packwiz` from a pinned commit in a Go
  stage and copies it onto `python:3.14-alpine` (also used by `scripts/make-servers-dat.py`).
  All linters run from pinned container images with least-privilege read-only staged mounts.

## Consequences

- No custom JVM, mod loader, or backup logic to maintain; updates are explicit digest bumps.
- Every pulled image pin must be a multi-arch manifest list digest so both `amd64` and
  `arm64` hosts pull cleanly.
- Tool containers run as the host user (`UID`/`GID`) and never mount `.env`, world data,
  backups, staging copies, or `.git`.
- Docker preserves the last health status across stop/start until a new probe executes, so
  `scripts/lib.sh` requires a fresh health probe timestamp before reporting healthy.
- Accepted trust boundary: the Fabric loader, vanilla server JAR, and JRE are downloaded
  by `itzg/minecraft-server` over TLS from Mojang and Fabric meta using pinned versions;
  every mod JAR is SHA-512 pinned in `pack/`.
