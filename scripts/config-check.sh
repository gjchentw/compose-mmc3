#!/usr/bin/env bash
# Assert static contracts on the rendered Compose configurations (L1):
#   - no service fixes a container name;
#   - no locally built image is tagged with a fixed name;
#   - every pulled image carries a version tag (not latest/stable) and @sha256: digest;
#   - the services are minecraft and backup, plus packwiz under the tools profile;
#   - the staging project name follows STAGING_PROJECT_NAME and differs from production's;
#   - packwiz mounts only pack/ (rw), scripts/ (ro), and dist/ (ro).
#
# Both file sets are rendered with the environment files Compose would read
# (scripts/lib.sh), so a missing RCON_PASSWORD or PACK_VERSION fails here as it
# does for `docker compose config`.
#
# Usage: scripts/config-check.sh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"
# shellcheck source=scripts/lib.sh
. "$repo_root/scripts/lib.sh"

expected_services="backup minecraft packwiz"
# <source relative to the repository>:<rw|ro>, sorted; ./ is the repository root.
expected_tool_mounts="dist:ro pack:rw scripts:ro"
failures=0
bad() { log "FAIL: $*"; failures=$((failures + 1)); }

# The file sets are named explicitly: a COMPOSE_FILE in the caller's shell must
# not decide what is checked.
render() {
  local label="$1"
  shift
  docker compose "$@" --profile tools config \
    || fail "cannot render the $label configuration (see the message above)"
}

# offenders KEY: the services in the rendered configuration on stdin that set
# KEY ("container_name"), or, for "tagged-build", both build: and image:, or,
# for "unpinned-image", a pulled image missing a non-floating tag and @sha256: digest.
offenders() {
  awk -v want="$1" '
    /^[^ #]/ { in_services = ($0 == "services:"); next }
    !in_services { next }
    /^  [^ ]/ { svc = $1; sub(/:$/, "", svc); next }
    /^    container_name:/ { named[svc] = 1 }
    /^    build:/ { built[svc] = 1 }
    /^    image:/ {
      img = $2
      gsub(/^["'\'']|["'\'']$/, "", img)
      tagged[svc] = img
    }
    END {
      for (s in named) if (want == "container_name") print s
      for (s in built) if (want == "tagged-build" && (s in tagged)) print s
      for (s in tagged) {
        if (want == "unpinned-image" && !(s in built)) {
          img = tagged[s]
          if (img !~ /:[^:@]+@sha256:[0-9a-f]{64}$/ || img ~ /:(latest|stable)@/) {
            print s "(" img ")"
          }
        }
      }
    }' | sort | tr '\n' ' ' | sed 's/ $//'
}

project_name() { sed -n 's/^name: //p' | head -n 1 | tr -d "\"'"; }

# mounts_of SERVICE: the mounts of SERVICE in the rendered configuration on
# stdin, as <source relative to the repository>:<rw|ro>, sorted, on one line.
mounts_of() {
  awk -v want="$1" -v root="$repo_root" '
    function flush(rel) {
      if (src == "") return
      rel = src
      if (rel == root) rel = "./"
      else if (index(rel, root "/") == 1) rel = substr(rel, length(root) + 2)
      print rel ":" mode
      src = ""
    }
    /^[^ #]/ { flush(); in_services = ($0 == "services:"); next }
    !in_services { next }
    /^  [^ ]/ { flush(); svc = $1; sub(/:$/, "", svc); in_volumes = 0; next }
    svc != want { next }
    /^    [^ ]/ { flush(); in_volumes = ($1 == "volumes:"); next }
    !in_volumes { next }
    /^      - / { flush(); src = "?"; mode = "rw"; next }
    /^        source: / { src = $2; next }
    /^        read_only: true$/ { mode = "ro"; next }
    END { flush() }' | sort | tr '\n' ' ' | sed 's/ $//'
}

prod="$(render production -f compose.yaml)"
staging="$(render staging -f compose.yaml -f compose.staging.yaml)"

for label in production staging; do
  if [ "$label" = production ]; then rendered="$prod"; else rendered="$staging"; fi
  found="$(printf '%s\n' "$rendered" | offenders container_name)"
  [ -z "$found" ] || bad "$label: container_name is fixed on: $found (Compose must name the containers)"
  found="$(printf '%s\n' "$rendered" | offenders tagged-build)"
  [ -z "$found" ] || bad "$label: a locally built image has a fixed image: tag on: $found"
  found="$(printf '%s\n' "$rendered" | offenders unpinned-image)"
  [ -z "$found" ] || bad "$label: pulled image is not pinned by non-floating tag and @sha256 digest: $found"
  services="$(printf '%s\n' "$rendered" | awk '
    /^[^ #]/ { in_services = ($0 == "services:"); next }
    in_services && /^  [^ ]/ { s = $1; sub(/:$/, "", s); print s }' | sort | tr '\n' ' ' | sed 's/ $//')"
  [ "$services" = "$expected_services" ] \
    || bad "$label: services are '$services', expected '$expected_services'"
  found="$(printf '%s\n' "$rendered" | mounts_of packwiz)"
  [ "$found" = "$expected_tool_mounts" ] \
    || bad "$label: the packwiz service mounts '$found', expected '$expected_tool_mounts' (only the pack writable)"
done

prod_name="$(printf '%s\n' "$prod" | project_name)"
staging_name="$(printf '%s\n' "$staging" | project_name)"
want_name="$(env_value STAGING_PROJECT_NAME 2>/dev/null || true)"
want_name="${want_name:-minecraft-staging}"
[ -n "$prod_name" ] && [ -n "$staging_name" ] || bad "cannot read the project names from the rendered configurations"
# A literal name equal to the default would pass the comparison below, so the
# override is also rendered with a probe value, which it must follow.
probe="$(STAGING_PROJECT_NAME=config-check-probe render staging -f compose.yaml -f compose.staging.yaml | project_name)"
[ "$probe" = "config-check-probe" ] \
  || bad "the staging project name does not follow STAGING_PROJECT_NAME: a probe value gave '$probe'"
[ "$staging_name" = "$want_name" ] \
  || bad "the staging project is '$staging_name', not STAGING_PROJECT_NAME ('$want_name'); is COMPOSE_PROJECT_NAME set in the shell or in .env?"
[ "$staging_name" != "$prod_name" ] \
  || bad "staging and production share the project name '$prod_name': staging would take over production's containers"

[ "$failures" -eq 0 ] || fail "$failures configuration check(s) failed"
log "CONFIG OK: production is project '$prod_name', staging is '$staging_name'; services $expected_services; images pinned; no fixed container or image name; packwiz mounts $expected_tool_mounts"
