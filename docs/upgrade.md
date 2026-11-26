# Upgrade SOP

Standard operating procedure for upgrading the modpack, pinned container images, or stack configuration with branch acceptance on staging before merging to `main`.

## 1. Prepare the branch

1. Create a feature branch and complete the OpenSpec change (`propose` → human approval → `apply`).
2. Run local L1 and L2 checks before pushing:

   ```bash
   scripts/lint.sh
   scripts/config-check.sh
   scripts/version-check.sh
   docker compose --profile tools build
   docker compose --profile tools run --rm -T packwiz refresh && git diff --exit-code pack/
   ver="$(bash -c '. scripts/lib.sh && commit_version')"
   scripts/pack-export.sh "$ver"
   scripts/pack-inspect.sh --expect "$ver"
   scripts/pack-publish.sh --dry-run
   git restore dist/ 2>/dev/null || rm -rf dist/mmc3.mrpack dist/mmc3.env
   ```

3. Push the branch and verify CI L1 and L2 pass (optionally push a `smoke/<name>` branch to also run L3 and L4 on a hosted Linux runner).

## 2. Accept the branch on staging (Docker host)

Keep the production checkout on `main` throughout. Run staging from a separate checkout or `git worktree` of the candidate branch:

1. Create a worktree for the candidate branch and copy `.env` into it:

   ```bash
   git worktree add ../compose-mmc3-staging <branch>
   cp .env ../compose-mmc3-staging/.env
   ```

2. Build the candidate branch's pack inside the staging worktree (overriding `SERVER_PUBLIC_HOST` with the staging port so testers join staging directly):

   ```bash
   cd ../compose-mmc3-staging
   docker compose --profile tools build
   SERVER_PUBLIC_HOST="<your-host>:25566" scripts/pack-export.sh
   ```

3. Clone the live production world safely into `staging/data`:

   ```bash
   scripts/staging-clone-world.sh --production /path/to/production/compose-mmc3
   ```

4. Start staging and run automated L3 and L4 checks against it:

   ```bash
   export COMPOSE_FILE=compose.yaml:compose.staging.yaml
   export COMPOSE_ENV_FILES=.env,dist/mmc3.env
   scripts/smoke.sh
   scripts/persist-test.sh
   scripts/restore-drill.sh
   ```

5. Send the candidate `dist/mmc3.mrpack` to at least two testers and complete [docs/acceptance-checklist.md](acceptance-checklist.md) (L5) on staging before merging.
6. Stop staging and clean up the worktree when done:

   ```bash
   docker compose down
   cd /path/to/production/compose-mmc3
   git worktree remove ../compose-mmc3-staging
   ```

## 3. Publish (CI)

1. Merge the pull request into `main`.
2. Wait for the `Publish the pack to main` CI job to finish. When the pack contents or `SERVER_NAME` changed (and `SERVER_PUBLIC_HOST` in `config/public.env` is non-empty), CI commits the updated `dist/mmc3.mrpack` and `dist/mmc3.env` to `main`. Replace the default placeholder `mc.example.com` with your real hostname before sharing the pack with players.

## 4. Upgrade production (Docker host)

1. Take a pre-upgrade backup and save a copy in `backups/keep/` (protected from pruning):

   ```bash
   scripts/restore-drill.sh
   cp "$(ls -t backups/*.tar.gz | head -n 1)" backups/keep/
   ```

2. Pull `main` (which brings both the updated code/Compose files and CI's `dist/mmc3.mrpack` + `dist/mmc3.env`):

   ```bash
   git pull --ff-only origin main
   ```

3. Pull any updated container images, stop gracefully, and restart:

   ```bash
   export COMPOSE_ENV_FILES=.env,dist/mmc3.env
   docker compose pull
   docker compose stop
   docker compose up -d
   ```

4. Run L3 smoke verification on production:

   ```bash
   scripts/smoke.sh
   ```

5. Complete [docs/acceptance-checklist.md](acceptance-checklist.md) (L5) on production and notify players to update their client pack from the fixed link.
