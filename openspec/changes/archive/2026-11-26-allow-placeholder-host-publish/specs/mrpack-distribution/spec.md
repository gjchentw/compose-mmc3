# Spec Delta

## REMOVED Requirements

### Requirement: Every change on main republishes the pack
**Reason**: The previous requirement included a scenario skipping publication when `SERVER_PUBLIC_HOST` is the placeholder `mc.example.com`. Publication now proceeds for any non-empty `SERVER_PUBLIC_HOST` (including `mc.example.com`) and skips only when `SERVER_PUBLIC_HOST` is empty or unset.
**Migration**: Replaced by `Every change on main republishes the pack for non-empty hosts` in this capability.

## ADDED Requirements

### Requirement: Every change on main republishes the pack for non-empty hosts
On every push to `main`, CI SHALL build the pack for the pushed commit whenever `SERVER_PUBLIC_HOST` in `config/public.env` is non-empty (including `mc.example.com`), compare its contents (ignoring the version) with `dist/<pack>.mrpack` and its display name with `dist/<pack>.env`, and commit both in one CI-skipping commit when either differs. When `SERVER_PUBLIC_HOST` is empty or unset, or both files match, nothing SHALL be committed.

#### Scenario: Pack contents changed on main
- **WHEN** a commit that modifies `pack/` or `config/public.env` with a non-empty `SERVER_PUBLIC_HOST` is pushed to `main`
- **THEN** CI commits updated `dist/<pack>.mrpack` and `dist/<pack>.env` in one commit

#### Scenario: Placeholder host publishes a pack
- **WHEN** `config/public.env` carries the default placeholder host `mc.example.com` and no matching pack is committed yet
- **THEN** CI commits `dist/<pack>.mrpack` (with a pre-filled entry pointing to `mc.example.com`) and `dist/<pack>.env` to `main`

#### Scenario: Empty public host skips publish
- **WHEN** `SERVER_PUBLIC_HOST` in `config/public.env` is empty or unset
- **THEN** the publish job reports that it skipped because `SERVER_PUBLIC_HOST` is empty, succeeds, and no pack is committed
