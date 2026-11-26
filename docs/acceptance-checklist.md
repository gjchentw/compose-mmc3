# Acceptance Checklist (L5)

Human acceptance run required before merging any change to the pack or Compose stack (on staging first, then on production after upgrade).

- At least **two players** participate across each run.
- Between the two runs, test **every launcher** covered by [docs/pack-install-guide.md](pack-install-guide.md) (Modrinth App and Prism Launcher) and record the launcher used.

## Run metadata

- Environment: `[ ] Staging` / `[ ] Production`
- Branch / Commit: `________________`
- Pack version (`dist/mmc3.env`): `________________`
- Player 1 & Launcher: `________________`
- Player 2 & Launcher: `________________`
- Date (UTC): `________________`

## Infrastructure checks (game-agnostic)

- [ ] **Login & public server info**: Pre-filled server entry shows `<SERVER_NAME> (<version>)`, live MOTD shows `<SERVER_NAME> | Pack <version>` (with `[STAGING] ` prefix on staging), server icon appears, and whitelisted players join cleanly while a non-whitelisted account is refused.
- [ ] **Server restart**: Administrator runs `docker compose stop && docker compose up -d`; server exits cleanly and players reconnect without errors.
- [ ] **World persistence**: Blocks placed and inventory items acquired before the restart remain intact after the restart.
- [ ] **External network reachability**: At least one player connects from outside the host's local network.
- [ ] **Fresh profile defaults & keybinds**: Fresh profile starts with render distance 10, simulation distance 6, 120 FPS cap; pressing `B` opens Traveler's Backpack without opening Xaero's waypoint dialog; `N` opens Xaero's New Waypoint; `M` opens Xaero's World Map; `R` performs Combat Roll. Keybinds remain intact after closing and relaunching.

## Gameplay checks (MMC3)

- [ ] **Better Combat & Combat Roll**: Equip a melee weapon (e.g., sword or RPG class weapon), confirm Better Combat swing animation and hit registration on a mob, and perform a Combat Roll dodge with `R`.
- [ ] **RPG Series spell binding & casting**: Craft or obtain a Spell Binding Table, a Spell Book (Wizard, Paladin, Priest, Archer, or Rogue/Warrior), and Runes; bind a spell and cast it successfully in-world without client or server errors.
- [ ] **Custom dungeons & structures**: Explore the Overworld (or locate via admin command) and verify custom structures from Dungeons and Taverns, Towns and Towers, or YUNG's Better Dungeons generate cleanly without chunk errors.
- [ ] **Waystones**: Craft or locate a Waystone, activate two Waystones, and teleport between them cleanly.
- [ ] **Traveler's Backpack**: Craft and equip a Traveler's Backpack, open it with `B`, store and retrieve items, and confirm contents persist across relog.
- [ ] **Death grave (`You're in Grave Danger`)**: Die in survival mode, confirm a grave spawns at the death location, and retrieve all items from the grave intact.
- [ ] **Farmer's Delight cooking**: Place a Cooking Pot over a heat source, look up a recipe in EMI, cook a meal, and eat it cleanly.
