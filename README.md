# compose-mmc3

A Docker Compose infrastructure template for deploying a curated Medieval MC 3 (MMC3)–style **Minecraft 1.21.1 Fabric** RPG server and automatically publishing a matching player `.mrpack` modpack.

## Highlights

- **Single source of truth (`pack/`)**: One `packwiz` modpack (50 pinned Modrinth mods: 40 `both` + 10 `client`, centered on Better Combat, Combat Roll, Daedelus's RPG Series + Spell Engine, Dungeons & Taverns, Towns & Towers, YUNG's Better structures, End Remastered, Bosses of Mass Destruction, Waystones, Traveler's Backpack, You're in Grave Danger, and Farmer's Delight Refabricated) feeds both `itzg/minecraft-server` and players' launchers.
- **Rolling pack publish from `main`**: Every merge to `main` rebuilds `dist/mmc3.mrpack` and `dist/mmc3.env` with a commit-derived version (`YYYY.MM.DD-<commit>`), pre-filled server entry (`servers.dat`), and matching MOTD (`<SERVER_NAME> | Pack <version>`). Players always download from one fixed URL:
  `https://raw.githubusercontent.com/<you>/<your-repo>/main/dist/mmc3.mrpack`
- **Hardened & reproducible**: Multi-arch digest-pinned container images, SHA-pinned GitHub Actions, online mode + enforced whitelist, internal-only RCON, secret-free scheduled tar backups (`itzg/mc-backup`), least-privilege tool and linter mounts, and side-by-side staging support.

## Quick start (administrators)

1. Edit `config/public.env` with your `SERVER_NAME` and `SERVER_PUBLIC_HOST`, replace `config/server-icon.png` (64x64 PNG) if desired, and commit to `main` so CI publishes `dist/mmc3.mrpack` and `dist/mmc3.env`.
2. On your Linux host, follow [docs/admin-guide.md](docs/admin-guide.md):

   ```bash
   mkdir -p data backups/keep dist && chmod 750 data backups
   cp .env.example .env   # set RCON_PASSWORD, UID, GID, MEMORY
   export COMPOSE_ENV_FILES=.env,dist/mmc3.env
   scripts/smoke.sh
   ```

## Player guides

- **Install & update**: [English](docs/pack-install-guide.md) | [繁體中文](docs/pack-install-guide.zh-TW.md)
- **Play guide (memory, RPG classes, keys, troubleshooting)**: [English](docs/play-guide.md) | [繁體中文](docs/play-guide.zh-TW.md)

## Version contract

In git, `pack/pack.toml` always holds `0.0.0-dev` and `.env.example` sets neither `PACK_VERSION` nor public identity variables. Only CI commits `dist/mmc3.mrpack` and `dist/mmc3.env` on `main` when pack contents or `SERVER_NAME` change (skipping while `SERVER_PUBLIC_HOST` is still `mc.example.com`). Deployments pull `main` and restart with `COMPOSE_ENV_FILES=.env,dist/mmc3.env`, keeping the server pack, MOTD, and player download link in lockstep.

## Repository layout

```text
compose.yaml              production stack: minecraft + backup (+ packwiz under profile "tools")
compose.staging.yaml      staging override: own project name, port 25566, staging/ data
.env.example              deployment variables with safe defaults or placeholders
pack/                     packwiz source of truth (pack.toml, index.toml, mods/*.pw.toml, options.txt)
tools/packwiz/Dockerfile  packwiz built from a pinned commit on python:3.14-alpine
config/public.env         display name and public address; edit and commit to publish your pack
config/server-icon.png    64x64 placeholder server icon
scripts/                  lint, config-check, version-check, pack-export, pack-inspect,
                          pack-publish, smoke, persist-test, restore-drill,
                          staging-clone-world, ci-env, lib
dist/                     mmc3.mrpack and mmc3.env, committed by CI only on main
docs/                     admin-guide, upgrade, rollback, acceptance-checklist,
                          bilingual player guides, adr/
.github/workflows/ci.yml  L1 + L2 on push/PR; rolling pack publish on main;
                          L3/L4 on workflow_dispatch or smoke/* branch
openspec/                 OpenSpec specs and changes; all work starts here as a change
.agents/skills/           OpenSpec and addyosmani/agent-skills project skills
AGENTS.md                 collaboration protocol, OpenSpec workflow, verification ladder, boundaries
```

Runtime directories (`data/`, `backups/`, `staging/`, `.build/`, `.env`) are gitignored and never committed.

## Decisions

See [docs/adr/](docs/adr/) for architectural decision records covering the single curated packwiz pack, `itzg` server and backup images, export-time `servers.dat` generation, and rolling publication from `main`.