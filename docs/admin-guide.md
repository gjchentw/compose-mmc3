# Admin Guide

Operational guide for running `compose-mmc3` on a single Linux host with Docker Compose.

## First deployment

1. Install Docker Engine with the Compose v2 plugin and `bash`.
2. Clone the repository on the Linux host (on `main`).
3. Create the runtime directories as the host administrator user with mode `750` before the first start (so Docker does not create them owned by `root`):

   ```bash
   mkdir -p data backups/keep dist
   chmod 750 data backups
   ```

4. Copy `.env.example` to `.env`, set your host `UID` and `GID` (`id -u`, `id -g`), and generate a strong `RCON_PASSWORD`:

   ```bash
   cp .env.example .env
   openssl rand -base64 32
   ```

   Edit `.env` to set `RCON_PASSWORD`, `UID`, `GID`, `TZ`, and `MEMORY` (`6G` default on a 12 GB+ host, `4G` on an 8 GB host). Never set `PACK_VERSION`, `SERVER_NAME`, or `SERVER_PUBLIC_HOST` in `.env`.

5. Configure your shell profile so Compose reads both `.env` and the committed version file:

   ```bash
   export COMPOSE_ENV_FILES=.env,dist/mmc3.env
   ```

6. Verify the public display name and hostname in `config/public.env` and replace `config/server-icon.png` (64x64 PNG) if desired. Once committed to `main`, CI publishes `dist/mmc3.mrpack` and `dist/mmc3.env` (for a local pre-publish test, run `scripts/pack-export.sh`).
7. Start the stack and run the L3 smoke check:

   ```bash
   scripts/smoke.sh
   ```

8. Whitelist your players and add operators over internal RCON:

   ```bash
   docker compose exec minecraft rcon-cli whitelist add <player>
   docker compose exec minecraft rcon-cli op <admin_player>
   ```

## Everyday commands

All administrative commands target the `minecraft` service through internal RCON:

```bash
# List online players
docker compose exec minecraft rcon-cli list

# Manage whitelist
docker compose exec minecraft rcon-cli whitelist list
docker compose exec minecraft rcon-cli whitelist add <player>
docker compose exec minecraft rcon-cli whitelist remove <player>

# View live server logs
docker compose logs -f --tail 100 minecraft

# Graceful restart
docker compose stop && docker compose up -d
```

## Two deployments on one host

Two repositories created from this template can coexist on one Linux host (each with its own production and staging stacks):

- Place each checkout in its own directory (Compose derives the production project name from the directory name).
- Give each deployment distinct `MC_PORT`, `STAGING_PORT`, and `STAGING_PROJECT_NAME` values in `.env`.
- Never set `COMPOSE_PROJECT_NAME` globally in the shell or in `.env`; doing so would override `compose.staging.yaml` and cause staging to take over production containers.

## Where things live

| Path | Purpose | Committed to git |
|---|---|---|
| `compose.yaml`, `compose.staging.yaml` | Production stack and minimal staging override | Yes |
| `config/public.env`, `config/server-icon.png` | Display name, public host, and 64x64 server icon | Yes |
| `pack/` | Single-source packwiz modpack definition | Yes |
| `dist/mmc3.mrpack`, `dist/mmc3.env` | Published client/server pack and version file | CI only, on `main` |
| `.env` | Host secrets (`RCON_PASSWORD`), ports, memory, UID/GID | Never |
| `data/` | Live Minecraft world, mods installed from pack, config, admin JSON | Never |
| `backups/` | Scheduled tar archives (`backups/keep/` is exempt from pruning) | Never |
| `staging/` | Staging world data and staging backups | Never |

## Backups

- The `backup` sidecar starts after `minecraft` reports healthy, takes a startup archive, and runs every `BACKUP_INTERVAL` (default `24h`), skipping when no players are online (`PAUSE_IF_NO_PLAYERS=true`).
- Top-level archives in `backups/` older than `PRUNE_BACKUPS_DAYS` (default `14`) are pruned automatically.
- Copy pre-upgrade or milestone archives into `backups/keep/` — pruning never touches `backups/keep/`.
- Run a non-destructive restore drill any time:

  ```bash
  scripts/restore-drill.sh
  # Or verify a specific kept archive:
  scripts/restore-drill.sh keep/<archive.tar.gz>
  ```

## Performance triage

- **High tick time / lag spikes**: check `docker compose logs --tail 100 minecraft` for `Can't keep up!` warnings, verify host swap is not active, and confirm `VIEW_DISTANCE` (default `10`) and `SIMULATION_DISTANCE` (default `6`) match host CPU capacity.
- **Heap sizing**: keep `MEMORY` at `6G` (12 GB+ host) or `4G` (8 GB host); avoid over-allocating beyond 8–10 GB where GC pauses worsen.
- **Container logs**: bounded by Compose `json-file` rotation (`max-size: 50m`, `max-file: 5`).

## Security

- `ONLINE_MODE`, `ENABLE_WHITELIST`, and `ENFORCE_WHITELIST` are hardcoded to `"true"` in `compose.yaml` and verified by `scripts/smoke.sh`.
- RCON (`25575`) is enabled only on the internal Compose network and never published on the host.
- `server.properties`, `.rcon-cli.env`, and `.rcon-cli.yaml` are excluded from backup archives (`EXCLUDES` in `compose.yaml`) and verified absent by `scripts/restore-drill.sh`.
- Tool containers (`packwiz` and containerized linters in `scripts/lint.sh`) never mount `.env`, `data/`, `backups/`, `staging/`, or `.git`.
