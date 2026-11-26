# Rollback SOP

Standard operating procedure for rolling back a broken upgrade or restoring a world archive without risking the live world.

## Principles

- Never delete the live world before a backup archive has been verified and extracted cleanly.
- Move the live world aside (`data/world.aside.<timestamp>`), start the restored stack, pass `scripts/smoke.sh`, and delete the aside copy only after verification succeeds.

## Steps

### 1. Choose and verify the backup archive first

Pick the target archive under `backups/` (for example, a pre-upgrade archive in `backups/keep/<archive.tar.gz>`) and verify it before touching `data/`:

```bash
export COMPOSE_ENV_FILES=.env,dist/mmc3.env
scripts/restore-drill.sh keep/<archive.tar.gz>
```

If the archive does not exist, is corrupt, or lacks `world/level.dat`, `whitelist.json`, or `ops.json`, `scripts/restore-drill.sh` fails immediately and `data/` remains untouched.

### 2. Revert the repository commit (if rolling back a stack or pack upgrade)

On `main`, revert the bad merge commit in a PR (preferred so CI republishes the previous pack cleanly) or check out the known-good commit on the host while preparing the revert:

```bash
git log -n 10 --oneline
# On a temporary host rollback before reverting on main:
git checkout <known-good-commit>
```

### 3. Extract the verified archive into a staging directory

```bash
ts="$(date +%Y%m%d-%H%M%S)"
mkdir -p ".build/rollback-$ts"
tar xzf "backups/keep/<archive.tar.gz>" -C ".build/rollback-$ts"
test -f ".build/rollback-$ts/world/level.dat"
```

### 4. Stop the server and move the live world aside

```bash
docker compose stop
mv data/world "data/world.aside.$ts"
mv ".build/rollback-$ts/world" data/world
for f in whitelist.json ops.json banned-players.json banned-ips.json; do
  [ -e ".build/rollback-$ts/$f" ] && cp -a ".build/rollback-$ts/$f" "data/$f"
done
rm -rf ".build/rollback-$ts"
```

### 5. Restart and verify

```bash
docker compose up -d
scripts/smoke.sh
```

### 6. Clean up the aside copy

Only after `scripts/smoke.sh` passes and a player confirms the world state in-game:

```bash
rm -rf "data/world.aside.$ts"
```
