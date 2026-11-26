#!/usr/bin/env bash
# L3 smoke test: start the stack and assert the runtime contract against
# pack/ and dist/mmc3.{mrpack,env}.
#
# Usage: scripts/smoke.sh
# Env:   SMOKE_TIMEOUT  seconds to wait for healthy (default 600)
#        COMPOSE_FILE   set to compose.yaml:compose.staging.yaml for staging
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"
# shellcheck source=scripts/lib.sh
. "$repo_root/scripts/lib.sh"

timeout="${SMOKE_TIMEOUT:-600}"
service="minecraft"
pack_file="dist/${PACK_BASE_NAME}.mrpack"
version_file="dist/${PACK_BASE_NAME}.env"

# Another file set than production's (staging) must not run under production's
# project name: Compose would treat production's containers as its own and
# recreate them with the staging settings. Refuse before anything is created.
if [ -n "${COMPOSE_FILE:-}" ] && [ "$COMPOSE_FILE" != "compose.yaml" ]; then
  this_project="$(docker compose config 2>/dev/null | sed -n 's/^name: //p' | head -n 1)"
  prod_project="$(COMPOSE_FILE=compose.yaml docker compose config 2>/dev/null | sed -n 's/^name: //p' | head -n 1)"
  if [ -n "$this_project" ] && [ "$this_project" = "$prod_project" ]; then
    fail "COMPOSE_FILE=$COMPOSE_FILE would run under production's project name '$prod_project' and take over its containers; unset COMPOSE_PROJECT_NAME (shell and .env) and set STAGING_PROJECT_NAME in .env instead"
  fi
fi

[ -n "$(env_value RCON_PASSWORD)" ] || fail "RCON_PASSWORD is empty; set a real one in .env"

for f in "$pack_file" "$version_file"; do
  [ -f "$f" ] || fail "$f is missing; run git pull on main, or scripts/pack-export.sh to build one"
done
if [ -f .env ] && grep -q '^PACK_VERSION=' .env; then
  fail "remove the PACK_VERSION line from .env: the version comes from $version_file"
fi
env_v="$(env_value PACK_VERSION)"
is_pack_version "$env_v" \
  || fail "PACK_VERSION must be YYYY.MM.DD-<7-character commit> or $PLACEHOLDER_VERSION, got: $env_v"

# The version file is only a claim; the version id inside the pack is the fact.
inside="$(docker compose --progress quiet run --rm --no-deps -T --entrypoint sh "$service" \
  -c 'unzip -p "$1" modrinth.index.json | jq -r .versionId' sh "/packs/${PACK_BASE_NAME}.mrpack" | tr -d '\r')"
[ "$inside" = "$env_v" ] \
  || fail "$pack_file carries version ${inside:-nothing readable} inside, but PACK_VERSION is $env_v"

minecraft="$(sed -n 's/^minecraft = "\(.*\)"$/\1/p' pack/pack.toml)"
key_mod_version="$(sed -n 's/^filename = "spell_engine-fabric-\(.*\)+.*"$/\1/p' pack/mods/spell-engine.pw.toml)"
[ -n "$minecraft" ] && [ -n "$key_mod_version" ] \
  || fail "cannot read the Minecraft or Spell Engine version from pack/"

server_jars=""
for f in pack/mods/*.pw.toml; do
  if grep -Eq '^side = "(both|server)"$' "$f"; then
    server_jars="$server_jars$(sed -n 's/^filename = "\(.*\)"$/\1/p' "$f")
"
  fi
done

log "== docker compose up -d"
docker compose --progress quiet up -d

log "== waiting up to ${timeout}s for healthy"
wait_healthy "$service" "$timeout" || fail "server did not become healthy"

log "== status query"
status="$(docker compose exec -T "$service" mc-monitor status --host localhost --port 25565)"
log "$status"
printf '%s' "$status" | grep -Fc "version=$minecraft" >/dev/null || fail "status does not report version $minecraft"
printf '%s' "$status" | grep -Fc "Pack $env_v" >/dev/null || fail "MOTD does not announce Pack $env_v"

# Only this boot's output: the container log since its last start.
log "== current boot log (container output since start)"
started="$(docker inspect -f '{{.State.StartedAt}}' "$(docker compose ps -q "$service")")"
bootlog="$(docker compose logs --no-color --since "$started" "$service")"
printf '%s' "$bootlog" | grep -c 'Done (' >/dev/null || fail "boot log has no 'Done (' line"
printf '%s' "$bootlog" | grep -Ec -- "- spell_engine ${key_mod_version//./\\.}" >/dev/null \
  || fail "Fabric did not list spell_engine $key_mod_version in its mod table"
log "Fabric loaded spell_engine $key_mod_version"

log "== server-side mod set must be exactly the pack's server-side files"
mods="$(docker compose exec -T "$service" sh -c 'ls /data/mods' | tr -d '\r')"
log "$mods"
if ! diff <(printf '%s' "$server_jars" | sort) <(printf '%s\n' "$mods" | sort) >&2; then
  fail "/data/mods differs from the server-side set in pack/mods (see diff above)"
fi

log "== JVM, security properties, backup sidecar"
docker compose exec -T "$service" java -version 2>&1 | grep -c 'version "21\.' >/dev/null || fail "server JVM is not Java 21"
props="$(docker compose exec -T "$service" grep -Ec '^(online-mode|white-list|enforce-whitelist)=true$' /data/server.properties | tr -d '\r')"
[ "$props" = "3" ] || fail "online-mode, white-list and enforce-whitelist must all be true in server.properties (found $props)"
[ -n "$(docker compose ps -q --status running backup)" ] || fail "backup sidecar is not running"

log "== published port reachable from the host, RCON not published"
mapping="$(docker compose port "$service" 25565 | head -n 1)"
port="${mapping##*:}"
[ -n "$port" ] || fail "port 25565 is not published"
(exec 3<>"/dev/tcp/127.0.0.1/$port") 2>/dev/null || fail "nothing accepts connections on 127.0.0.1:$port"
log "tcp connect to 127.0.0.1:$port ok"
if [ -n "$(docker compose port "$service" 25575 2>/dev/null)" ]; then
  fail "RCON port 25575 is published on the host"
fi

log "SMOKE OK"
