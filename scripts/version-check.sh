#!/usr/bin/env bash
# Assert the git version contract (L2):
#   - pack/pack.toml carries only the placeholder version 0.0.0-dev;
#   - .env.example does not set PACK_VERSION (it comes from dist/mmc3.env);
#   - .env.example does not set SERVER_NAME or SERVER_PUBLIC_HOST (public info
#     lives in config/public.env).
#
# Usage: scripts/version-check.sh
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"
# shellcheck source=scripts/lib.sh
. "$repo_root/scripts/lib.sh"

failures=0
bad() { log "FAIL: $*"; failures=$((failures + 1)); }

v="$(pack_version)"
[ "$v" = "$PLACEHOLDER_VERSION" ] \
  || bad "pack/pack.toml version is '$v'; git must hold only the placeholder '$PLACEHOLDER_VERSION'"

if grep -qE '^PACK_VERSION=' .env.example; then
  bad ".env.example sets PACK_VERSION; the version comes from dist/${PACK_BASE_NAME}.env"
fi
if grep -qE '^(SERVER_NAME|SERVER_PUBLIC_HOST)=' .env.example; then
  bad ".env.example sets SERVER_NAME or SERVER_PUBLIC_HOST; public info lives in $PUBLIC_INFO_FILE"
fi
if [ -e pack/servers.dat ]; then
  bad "pack/servers.dat must not be committed; it is generated at export time"
fi

[ "$failures" -eq 0 ] || fail "$failures version contract check(s) failed"
log "VERSION OK: git holds only the placeholder $PLACEHOLDER_VERSION"
