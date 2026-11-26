# Tasks

## 1. Pack Export, Publish Scripts & CI Workflow

- [x] 1.1 Update `scripts/pack-publish.sh` and `scripts/pack-export.sh` to allow `SERVER_PUBLIC_HOST=mc.example.com` while still skipping publish / failing export when `SERVER_PUBLIC_HOST` is empty or unset; verify with `scripts/lint.sh`, `scripts/version-check.sh`, `scripts/pack-export.sh`, `scripts/pack-inspect.sh`, and `scripts/pack-publish.sh --dry-run` (proving dry-run reports it would commit with `mc.example.com` and skips when `SERVER_PUBLIC_HOST` is empty) (verify: L1, L2)
- [x] 1.2 Update `.github/workflows/ci.yml` publish job comments and step name to reflect skipping only when `SERVER_PUBLIC_HOST` is empty, and verify `scripts/lint.sh` (`actionlint` and `yamllint`) and `scripts/version-check.sh` pass (verify: L1, L2)

## 2. Config Comments, ADR & Documentation Sync

- [ ] 2.1 Update `config/public.env` comments, `README.md`, `docs/upgrade.md`, and `docs/adr/0003-servers-dat-generated-at-export.md` so documentation matches the new publish behavior, then run the full L1 and L2 verification suite (`scripts/lint.sh`, `docker compose config -q` for prod and staging, `scripts/config-check.sh`, `scripts/version-check.sh`, `scripts/pack-export.sh`, `scripts/pack-inspect.sh`, `scripts/pack-publish.sh --dry-run`) with a clean working tree afterward (verify: L1, L2)

## Workflow follow-up

- After human approval, archive `allow-placeholder-host-publish` in its own commit (`openspec archive allow-placeholder-host-publish`) so the modified requirement merges into `openspec/specs/mrpack-distribution/spec.md`.
- Merge the PR to `main` and confirm CI's `Publish the pack to main` job commits `dist/mmc3.mrpack` and `dist/mmc3.env`.
