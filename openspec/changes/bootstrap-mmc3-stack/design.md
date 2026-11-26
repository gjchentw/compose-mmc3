# Design

## Context

`compose-mmc3` is a greenfield Docker Compose infrastructure repository with `AGENTS.md`, OpenSpec v2.2.0, and `addyosmani/agent-skills` initialized, and no stack, modpack, verification scripts, CI, or guides yet. See `proposal.md` for motivation and scope.

This design adopts the proven four-capability architecture of `gjchentw/compose-cobblemon`, keeping game-agnostic infrastructure mechanisms cleanly separated from Medieval MC 3 (MMC3)–specific game values:

```text
 public-server-info  --(name, address, icon, MOTD)-------------> compose-services
 public-server-info  --(name, address)-------------------------> mrpack-distribution
 game-requirements   --(mods, sides, versions, client options)-> mrpack-distribution
 game-requirements   --(gameplay defaults, Java, key mod)------> compose-services
 mrpack-distribution --(pack file + version)-------------------> compose-services
```

## Goals / Non-Goals

**Goals:**
- Keep `compose-services`, `mrpack-distribution`, and `public-server-info` completely free of game-specific names, versions, or mod assumptions; isolate every MMC3 value in `game-requirements`.
- Produce a single-source-of-truth `packwiz` modpack (`pack/` → `dist/mmc3.mrpack` + `dist/mmc3.env`) whose `.mrpack` is small enough (kilobytes) to publish via CI rolling commits on `main` and feed both `itzg/minecraft-server` (`TYPE=MODRINTH`) and players' launchers (Modrinth App / Prism Launcher).
- Enforce the five-level verification ladder (L1 static/lint/config contract, L2 build/export/inspect/version contract, L3 smoke, L4 persistence & restore drill, L5 human acceptance) with least-privilege tool and linter container mounts.
- Keep deployments coexistable on a single Linux host (role-named services `minecraft`, `backup`, `packwiz`; no fixed `container_name` or shared local image tag).

**Non-Goals:**
- Supporting CurseForge mod downloads or mixed Modrinth/CurseForge manifests.
- Bundling shaderpacks, resourcepacks, FancyMenu assets, or custom KubeJS scripts into `pack/`.
- Introducing custom sidecars or wrappers where standard Docker Compose (`healthcheck`, `depends_on`, `stop_grace_period`, `logging`) or `itzg` built-in features suffice.

## Decisions

### 1. Four-capability boundary split
- **Decision:** Partition specs into `compose-services`, `mrpack-distribution`, `public-server-info`, and `game-requirements`, with documentation and verification checks owned by their respective capabilities (`docs/admin-guide.md`, `upgrade.md`, `rollback.md` → `compose-services`; `docs/pack-install-guide*.md` → `mrpack-distribution`; `docs/play-guide*.md` → `game-requirements`). Secrets never enter specs.
- **Alternatives considered:**
  - *Single monolithic spec*: rejected because changing the modpack or game would tangle infrastructure invariants with mod versions and gameplay defaults.
  - *Separating backup into a fifth capability*: rejected because backup is tightly coordinated with the game service over internal RCON and shares the same Compose lifecycle and restore/rollback runbooks.

### 2. Curated 50-mod packwiz MMC3-style modpack vs. upstream MMC3
- **Decision:** Build a curated Medieval Fantasy RPG modpack on Minecraft `1.21.1` / Fabric `0.20.1` / Java `21` using `packwiz` with 50 Modrinth mods (25 gameplay/performance roots + 15 required libraries on `both` sides, and 10 `client`-only optimization/UI mods), centered on Daedelus's RPG Series (`spell-engine`, `wizards`, `paladins-and-priests`, `archers`, `rogues-and-warriors`, `jewelry`, `relics-rpg`), `better-combat`, `combat-roll`, curated structures (`dungeons-and-taverns`, `towns-and-towers`, three `yungs-better-*` overhauls), `endrem`, `bosses-of-mass-destruction`, `waystones`, `travelersbackpack`, `yigd`, and `farmers-delight-refabricated`.
- **Alternatives considered:**
  - *Wrapping upstream Modrinth MMC3 v18 (334 mods, 57 MB)*: rejected because upstream Modrinth stopped updating in March 2025, marks all 334 mods `server: required` (no client/server separation), bundles 5,852 override files (62 MB uncompressed, including FancyMenu assets and 13 raw jars), and would bloat git history on every rolling publish.
  - *Running upstream CurseForge MMC3 v32 via `TYPE=AUTO_CURSEFORGE`*: rejected because it breaks the Modrinth-only single-pack architecture, requires a CurseForge API key, and forces separate server/client distribution paths.
  - *Including mob auto-leveling (`RPG Difficulty` / `AutoLeveling`), temperature/seasons (`Frostiful` / `Scorchful`), and 15+ structure packs*: rejected based on 2025–2026 community reports of HP-sponge bosses, chunkgen lag, and early-game loot bloat.

### 3. Two-bucket side classification (`both` and `client`) for worldgen mods
- **Decision:** Mark worldgen/structure mods (`dungeons-and-taverns`, `towns-and-towers`, `yungs-better-*`, `structure-pool-api`, `cristel-lib`, `yungs-api`) as `side = "both"` rather than `"server"`.
- **Alternatives considered:**
  - *Marking worldgen mods `side = "server"`*: rejected because players testing the exported `.mrpack` in singleplayer would get vanilla worlds without dungeons/structures, and keeping a strict two-bucket (`both` / `client`) model mirrors `compose-cobblemon` and simplifies inspection.

### 4. Container images, role naming, and least-privilege mounts
- **Decision:** Use pinned multi-arch digest references for `docker.io/itzg/minecraft-server:2026.10.1-java21` and `docker.io/itzg/mc-backup:2026.10.3`, and build `tools/packwiz/Dockerfile` from pinned `golang:1.25-alpine` + `python:3.14-alpine` digests and a pinned `packwiz` commit. Name services `minecraft`, `backup`, and `packwiz` (under profile `tools`), with no `container_name` or fixed local image tag. Mount only `pack/` (rw), `scripts/` (ro), and `dist/` (ro) into `packwiz`, and copy only target files + config into temporary read-only staging directories for containerized linters so `.env`, `data/`, `backups/`, `staging/`, and `.git/` are never exposed.
- **Alternatives considered:**
  - *Custom Minecraft server Dockerfile or host cron backups*: rejected in favor of maintained `itzg/*` images with built-in Modrinth `.mrpack` server-side installation, `mc-health`, and RCON-coordinated `save-off`/`save-on` backups (recorded in ADRs).
  - *Mounting the repository root into linters and `packwiz`*: rejected because it exposes `.env` (RCON password) and `.git` to third-party tool containers.

### 5. Rolling pack publishing from `main` via `config/public.env`
- **Decision:** Store `0.0.0-dev` in `pack/pack.toml` and never commit `PACK_VERSION` in `.env.example`. `scripts/pack-export.sh` substitutes `YYYY.MM.DD-<commit>`, generates `servers.dat` from `config/public.env` (`SERVER_NAME`, `SERVER_PUBLIC_HOST`), and writes `dist/mmc3.mrpack` and `dist/mmc3.env`. On pushes to `main` (non-fork, non-placeholder host), CI compares normalized pack contents and `SERVER_NAME` and commits updated `dist/mmc3.*` only when changed.
- **Alternatives considered:**
  - *GitHub Releases triggered by git tags*: rejected because rolling publish from `main` gives players one fixed download URL (`raw.githubusercontent.com/<owner>/<repo>/main/dist/mmc3.mrpack`) and lets deployers update with a single `git pull` + restart without editing `.env`.
  - *Storing `SERVER_NAME` / `SERVER_PUBLIC_HOST` in GitHub repository secrets*: rejected because display name and public address are public metadata, and keeping them in `config/public.env` allows template copies to publish immediately from the GitHub web editor without configuring secrets.

### 6. Smoke contract key mod and client keybind deconfliction
- **Decision:** Use `spell_engine` as the key mod checked in Fabric's boot log by `scripts/smoke.sh`, and ship a single client settings file `pack/options.txt` (`version:3955`) that keeps Traveler's Backpack on `B`, Combat Roll on `R`, and Xaero's World Map on `M`, while rebinding Xaero's Minimap new waypoint from `B` to `N`.
- **Alternatives considered:**
  - *Checking only `fabric-api` in smoke*: rejected because `fabric-api` does not prove the RPG mod stack loaded.
  - *Leaving Xaero's Minimap on `B`*: rejected because pressing `B` to open Traveler's Backpack would simultaneously trigger Xaero's new-waypoint dialog.

## Risks / Trade-offs

- **[Mod version inter-compatibility across 50 mods (including `bosses-of-mass-destruction` beta, `playeranimator` beta, and `ranged-weapon-api` 3.0.0 with RPG Series 3.1.3 / `jewelry` 2.5.1 / `relics-rpg` 1.4.0)]** → Verified during L2 `packwiz` assembly and L3 `scripts/smoke.sh` real server boot; if Fabric loader reports a version constraint mismatch at boot, pin the exact compatible Modrinth release and update `game-requirements` before completing Apply.
- **[Exact `options.txt` keybind identifier for Xaero's Minimap new-waypoint key]** → Verify the exact key translation string from the `xaeros-minimap` JAR (`assets/xaerominimap/lang/en_us.json` / mod classes) during Apply so the binding survives first launch and write-back.
- **[Modded server startup time and memory on 40 server-side mods]** → `compose.yaml` keeps `start_period: 5m`, `retries: 20` (up to 600 s smoke timeout), `USE_AIKAR_FLAGS: "true"`, and `Lithium` + `FerriteCore` + `ModernFix` on the server; L3 smoke on Linux verifies real startup duration and heap stability.
- **[Upstream pinned image digests (`itzg/minecraft-server`, `itzg/mc-backup`, linter images)]** → Verify multi-arch (`linux/amd64` + `linux/arm64`) manifest digests against registries during Apply so builds remain reproducible on both architectures.

## Migration Plan

1. Review and approve this change at the **Propose gate** (`openspec validate bootstrap-mmc3-stack` passes).
2. Execute tasks incrementally in **Apply**, verifying each task against its declared verification levels (L1–L4) and committing one task per commit on `feat/bootstrap-mmc3-stack`.
3. Push a `smoke/*` branch (or trigger `workflow_dispatch`) to verify L3/L4 on the hosted GitHub Actions Linux runner, and complete L5 gameplay acceptance with players on staging.
4. Merge to `main` (human decision) and run **Archive** (`openspec archive bootstrap-mmc3-stack`) in its own commit so all four capabilities merge into `openspec/specs/`.
