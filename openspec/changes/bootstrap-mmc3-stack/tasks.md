# Tasks

## 1. Repository Foundations & Static Verification Harness

- [x] 1.1 Add `.gitignore`, `.yamllint.yaml`, `.hadolint.yaml`, `scripts/lib.sh`, `scripts/ci-env.sh`, and least-privilege containerized `scripts/lint.sh` (including a self-test proving linters see only copied target files and never `.env` or `.git`), then run `scripts/lint.sh` (verify: L1)
- [x] 1.2 Add `config/public.env` (placeholder `SERVER_NAME=MMC3 Server` and `SERVER_PUBLIC_HOST=mc.example.com`) and a 64x64 placeholder `config/server-icon.png`, and verify lint plus PNG dimensions (verify: L1)

## 2. Docker Compose Stack & Config Contract

- [x] 2.1 Add `compose.yaml`, `compose.staging.yaml`, `.env.example`, and `tools/packwiz/Dockerfile` with role-named services (`minecraft`, `backup`, `packwiz`), pinned multi-arch image digests, least-privilege `packwiz` mounts, internal-only RCON, online mode, and enforced whitelist, and verify `docker compose config -q` for both production and staging sets (verify: L1)
- [x] 2.2 Add `scripts/config-check.sh` asserting rendered production and staging configurations have no fixed `container_name` or shared local image tag, pin all pulled images by multi-arch digest, and enforce least-privilege `packwiz` mounts, then run `scripts/lint.sh` and `scripts/config-check.sh` (verify: L1)
- [x] 2.3 Record foundational architectural decisions in `docs/adr/` (`0001-single-pack-for-client-and-server.md`, `0002-itzg-image-and-mc-backup-sidecar.md`, `0003-servers-dat-generated-at-export.md`, `0004-rolling-pack-from-main.md`) and verify `scripts/lint.sh` passes (verify: L1)

## 3. Curated MMC3 Packwiz Source & Export/Inspection Pipeline

- [x] 3.1 Build the `packwiz` tools image, initialize `pack/` (`pack.toml` with placeholder `0.0.0-dev`, Minecraft `1.21.1`, Fabric `0.20.1`), add all 50 Modrinth mods (40 `both` and 10 `client`), and verify `docker compose --profile tools run --rm -T packwiz refresh` leaves `pack/` unchanged (verify: L1, L2)
- [x] 3.2 Verify the exact Xaero's Minimap new-waypoint keybind identifier from the pinned mod JAR, add `pack/options.txt` (`version:3955`, declared client defaults, Traveler's Backpack on `B`, Xaero's Minimap new waypoint on `N`, Xaero's World Map on `M`, Combat Roll on `R`), and verify `packwiz refresh` is a no-op (verify: L1, L2)
- [x] 3.3 Add `scripts/version-check.sh`, `scripts/make-servers-dat.py`, `scripts/pack-export.sh`, `scripts/pack-inspect.py`, `scripts/pack-inspect.sh`, and `scripts/pack-publish.sh` with the exact 50-mod side table and `mmc3` pack base name, then verify version contract, export, strict inspection, and publish dry-run pass (verify: L1, L2)

## 4. Runtime Verification Scripts (Smoke, Persistence & Restore Drill)

- [ ] 4.1 Add `scripts/smoke.sh` enforcing preflight version/project-name checks, server health within 600s, Minecraft `1.21.1`, Java 21, `spell_engine` key mod loaded, exact 40 server-side mods installed, MOTD contract, internal-only RCON, online mode/whitelist enabled, and running `backup` service; run `scripts/smoke.sh` on a local test deployment (verify: L1, L2, L3)
- [ ] 4.2 Add `scripts/persist-test.sh`, `scripts/restore-drill.sh`, and `scripts/staging-clone-world.sh`, and run both `scripts/persist-test.sh` and `scripts/restore-drill.sh` to prove clean shutdown persistence and secret-free archive restoration (verify: L1, L2, L4)

## 5. CI Workflow, Documentation & Harness Sync

- [ ] 5.1 Add `.github/workflows/ci.yml` with commit-SHA-pinned actions, least-privilege token permissions, L1/L2 on every push and pull request, rolling publish of `dist/mmc3.mrpack` and `dist/mmc3.env` on non-fork pushes to `main` (skipping placeholder host), and hosted Linux L3/L4 on `workflow_dispatch` or `smoke/*` branches; verify lint passes (verify: L1, L2)
- [ ] 5.2 Add administrator runbooks (`docs/admin-guide.md`, `docs/upgrade.md`, `docs/rollback.md`), player acceptance checklist (`docs/acceptance-checklist.md`), and bilingual player guides (`docs/pack-install-guide.md`, `docs/pack-install-guide.zh-TW.md`, `docs/play-guide.md`, `docs/play-guide.zh-TW.md`) adhering to capability ownership and link separation; verify lint passes (verify: L1)
- [ ] 5.3 Update `AGENTS.md` and `README.md` with finalized repository layout, capability boundaries, concrete verification commands, and pack/version boundaries, and run the full L1 and L2 suite (verify: L1, L2)

## 6. End-to-End Integration Verification

- [ ] 6.1 Run the full L1–L4 verification suite end-to-end (including hosted Linux CI verification on a `smoke/*` branch or `workflow_dispatch`) and confirm a clean working tree with no committed secrets or runtime artifacts (verify: L1, L2, L3, L4)

## Workflow follow-up

- Complete L5 player gameplay acceptance on staging with at least two players across Modrinth App and Prism Launcher before merging to `main`.
- After merge approval and deployment, archive `bootstrap-mmc3-stack` via `openspec archive bootstrap-mmc3-stack` in its own commit so all four specs merge into `openspec/specs/`.
