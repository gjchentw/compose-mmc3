# ADR 0004: Rolling pack publication from main with commit-derived versions

Status: accepted, 2026-11-26

## Context

Tag-driven GitHub Releases require operators to cut manual tags and update release links
or `.env` version variables on every mod bump, and template users who only edit
`config/public.env` in the GitHub web UI cannot easily run local export scripts.

## Decision

- `pack/pack.toml` always holds the placeholder `0.0.0-dev`, and `.env.example` never sets
  `PACK_VERSION`.
- Every built pack receives a commit-derived version `YYYY.MM.DD-<7-char-commit>` (UTC
  committer date and short SHA).
- On every push to `main` (non-fork, real `SERVER_PUBLIC_HOST`), CI exports the pack,
  compares normalized pack contents and `SERVER_NAME` against the committed
  `dist/mmc3.mrpack` and `dist/mmc3.env`, and commits both files together only when either
  changed.
- Players always download from one fixed URL (`raw.githubusercontent.com/<owner>/<repo>/main/dist/mmc3.mrpack`)
  and compare their server entry name `<SERVER_NAME> (<version>)` against the live MOTD
  `<SERVER_NAME> | Pack <version>`.
- Deployments read `COMPOSE_ENV_FILES=.env,dist/mmc3.env` so `git pull` + restart updates
  both the pack and the advertised MOTD version without editing `.env`.

## Consequences

- Releasing requires only merging a verified branch to `main`; template copies publish
  automatically after editing `config/public.env` in the browser.
- Every published pack is traceable in `git log main` via its commit-derived version.
- Only CI commits `dist/mmc3.mrpack` and `dist/mmc3.env`; local exports are restored with
  `git restore dist/`.
- Commit messages written by humans or agents must never contain a literal CI skip marker
  so pushes and squash merges never suppress CI or pack publication.
