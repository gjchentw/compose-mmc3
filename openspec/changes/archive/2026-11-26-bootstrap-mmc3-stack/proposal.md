# Proposal

## Why

`compose-mmc3` currently has only the repository harness (`AGENTS.md`, OpenSpec, and agent skills) and no server stack, modpack definition, verification scripts, CI pipeline, or documentation. We need to establish the baseline four-capability specification architecture (mirroring `gjchentw/compose-cobblemon`) and implement a reproducible, single-source-of-truth Docker Compose deployment and custom curated Medieval MC 3 (MMC3)–style Fabric 1.21.1 modpack (`mmc3.mrpack`).

## What Changes

- Establish four cleanly separated baseline capabilities following the `compose-cobblemon` boundary model:
  - `compose-services` (Docker Compose stack, backup sidecar, security posture, staging override, L3/L4 checks, and administrator runbooks)
  - `mrpack-distribution` (packwiz single-source pack build, commit-derived versioning, pre-filled `servers.dat` generation, strict pack inspection, least-privilege tooling/lint containers, CI rolling publish to `dist/mmc3.mrpack` and `dist/mmc3.env`, and player install/update guides)
  - `public-server-info` (committed `config/public.env` display name and public address, `config/server-icon.png`, and MOTD contract)
  - `game-requirements` (curated MMC3-style Minecraft 1.21.1 Fabric 0.20.1 / Java 21 modpack definition with 50 pinned Modrinth mods across `both` and `client` sides, server/client defaults, keybind conflict resolution, play guides, and gameplay acceptance checklist)
- Add the Docker Compose production (`compose.yaml`) and staging (`compose.staging.yaml`) stacks, `.env.example`, pinned `tools/packwiz/Dockerfile`, linter configs (`.yamllint.yaml`, `.hadolint.yaml`), `.gitignore`, `config/public.env`, `config/server-icon.png`, `pack/` packwiz source, verification and publish scripts (`scripts/`), CI workflow (`.github/workflows/ci.yml`), ADRs (`docs/adr/`), admin runbooks, acceptance checklist, bilingual player guides (`en` + `zh-TW`), and update `AGENTS.md` and `README.md` to reference concrete paths and scripts.

## Out of Scope

- Bundling the upstream 334-mod / 57 MB Luna Pixel Studios MMC3 CurseForge/Modrinth modpack or its FancyMenu / shaderpack / resourcepack asset overrides.
- CurseForge API integration or non-Modrinth mod hosting.
- Extra dimensions (`The Aether`, `Deeper and Darker`), mob auto-leveling (`RPG Difficulty`, `AutoLeveling`, `Eldritch Mobs`), or temperature/seasons survival mechanics (`Frostiful`, `Scorchful`, `Fabric Seasons`) in this baseline; any of those can be added later through dedicated OpenSpec changes.
- Automated host provisioning, reverse proxies, DNS management, or cloud deployment scripts outside Docker Compose on a single Linux host.

## Capabilities

### New Capabilities

- `compose-services`: Docker Compose Minecraft game server and backup sidecar stack, staging override, security and least-privilege posture, smoke/persistence/restore verification, and administrator documentation (game-agnostic mechanism).
- `mrpack-distribution`: Single-source `packwiz` `.mrpack` export, commit-derived rolling version contract, export-time `servers.dat` generation, strict pack inspection, least-privilege tool and linter mounts, CI build and publish workflow, and player install/update documentation.
- `public-server-info`: Deployer-supplied public server metadata (`config/public.env`, `config/server-icon.png`, MOTD formatting, and version-file name propagation).
- `game-requirements`: Curated MMC3-style Medieval Fantasy RPG game specification (Minecraft 1.21.1, Fabric 0.20.1, Java 21, 50-mod side table, key mod `spell_engine`, server defaults, client defaults and keybind deconfliction, play guides, and gameplay acceptance items).

### Modified Capabilities

<!-- None: this is the initial baseline change. -->

## Impact

- Creates the complete infrastructure, packwiz modpack source, verification harness, CI workflow, and documentation tree for `compose-mmc3`.
- Updates `AGENTS.md` and `README.md` once the concrete Compose files, scripts, CI workflow, and capability boundaries land.
- No external service credentials or repository secrets are required for L1–L4 CI or template pack publishing (all mods come from public `cdn.modrinth.com`).
