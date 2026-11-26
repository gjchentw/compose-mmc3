# Spec Delta

## Purpose
Declares the values the game dictates, which change when the mod set changes: the pack's identity, the curated MMC3-style Medieval Fantasy RPG mod set and sides, the Minecraft, Fabric loader, Spell Engine and Java versions, the server's gameplay defaults and heap, the client settings files and their defaults, keybind deconfliction, what players are taught, and the gameplay items of the acceptance run. It is the only capability to rewrite for another mod pack; the other three take every game value from here.

## ADDED Requirements

### Requirement: Game platform versions
The game SHALL be Minecraft 1.21.1 on the Fabric loader 0.20.1 with Spell Engine 1.10.9+1.21.1-fabric as the core RPG framework.

#### Scenario: Pack pins the platform
- **WHEN** the pack is exported
- **THEN** its index pins Minecraft `1.21.1` and `fabric-loader` `0.20.1`, and it contains `spell_engine-fabric-1.10.9+1.21.1.jar`

### Requirement: RPG combat and exploration mods (both sides)
The pack SHALL include these 16 RPG combat, dungeon, and boss mods on both sides: `better-combat`, `combat-roll`, `spell-engine`, `wizards`, `paladins-and-priests`, `archers`, `rogues-and-warriors`, `jewelry`, `relics-rpg`, `dungeons-and-taverns`, `towns-and-towers`, `yungs-better-dungeons`, `yungs-better-strongholds`, `yungs-better-nether-fortresses`, `endrem`, and `bosses-of-mass-destruction`.

#### Scenario: RPG and exploration mods installed on both sides
- **WHEN** the pack is inspected
- **THEN** all 16 RPG combat and exploration mods appear in the pack index as required on both client and server

### Requirement: Survival and shared platform mods (both sides)
The pack SHALL include these 9 survival QoL and shared performance mods on both sides: `waystones`, `travelersbackpack`, `yigd`, `farmers-delight-refabricated`, `fabric-api`, `lithium`, `ferrite-core`, `modernfix`, and `appleskin`.

#### Scenario: Survival and platform mods installed on both sides
- **WHEN** the pack is inspected
- **THEN** all 9 survival and shared platform mods appear in the pack index as required on both client and server

### Requirement: Required mod libraries (both sides)
The pack SHALL include these 15 required dependency libraries on both sides: `armor-model-api`, `balm`, `bundle-api`, `cardinal-components-api`, `cloth-config`, `cristel-lib`, `fabric-language-kotlin`, `geckolib`, `playeranimator`, `ranged-weapon-api`, `runes`, `spell-power`, `structure-pool-api`, `trinkets`, and `yungs-api`.

#### Scenario: Server installs all forty both-side mods
- **WHEN** the server installs the server side of the pack
- **THEN** it installs exactly the 25 core both-side mods and 15 required libraries (40 total) and none of the client-only mods

### Requirement: Client-only mods and exact side table
The pack SHALL include exactly these 10 client-only mods: `sodium`, `iris`, `immediatelyfast`, `entityculling`, `modmenu`, `placeholder-api`, `emi`, `xaeros-minimap`, `xaeros-world-map`, and `mouse-tweaks`. Together with the 40 both-side mods above, these 50 mods form the exact inspection reference table.

#### Scenario: Side table is the inspection reference
- **WHEN** the pack is inspected
- **THEN** the side of every mod matches this 50-mod table, and any extra, missing, or misclassified mod fails inspection

### Requirement: Java 21
The server and the players' launchers SHALL run Java 21, as required by Minecraft 1.21.1 and Fabric 0.20.1.

#### Scenario: Server JVM
- **WHEN** the smoke check queries the server's JVM
- **THEN** it reports major version 21

#### Scenario: Wrong Java on a client
- **WHEN** a player launches the pack with a Java version older than 21
- **THEN** the launcher or Minecraft refuses to start and reports Java 21 as required

### Requirement: Key mod is loaded
The server SHALL load Spell Engine (`spell_engine`) at the version the pack pins; this is the key mod the smoke check uses to verify that the RPG game framework, not just vanilla Minecraft, is running.

#### Scenario: Boot log lists Spell Engine
- **WHEN** the server finishes starting
- **THEN** Fabric's mod list in the boot log contains `spell_engine` at the pinned version

### Requirement: Server gameplay defaults
Unless the deployment overrides them, the server SHALL run with a 6 GB heap, at most 12 players, view distance 10, simulation distance 6, normal difficulty, survival mode and PvP off. A host with 8 GB of RAM SHALL use a 4 GB heap.

#### Scenario: Defaults applied
- **WHEN** the deployment environment file sets none of these values
- **THEN** the server runs with exactly these defaults

### Requirement: Client defaults
The pack SHALL carry exactly one client settings file of its own, `options.txt`. It SHALL set render distance 10, simulation distance 6, entity distance 75 %, decreased particles, biome blend 2, fast clouds and a 120 FPS limit, and start with the data version line of the Minecraft version (`version:3955` for 1.21.1).

#### Scenario: Fresh profile
- **WHEN** a player installs the pack into a new profile and starts the game
- **THEN** these options are in effect

#### Scenario: Settings files the pack carries
- **WHEN** the pack is inspected
- **THEN** `options.txt` is the only client settings file accepted besides the server entry that export generates

### Requirement: Key bindings do not conflict
Traveler's Backpack SHALL stay on `B`, Xaero's Minimap new-waypoint binding SHALL be moved to `N` instead of its default `B`, Xaero's World Map SHALL stay on `M`, and Combat Roll SHALL stay on `R`. These bindings SHALL survive the first launch of a fresh profile.

#### Scenario: Fresh profile keybinds
- **WHEN** a new player opens their backpack with `B`, opens the world map with `M`, adds a waypoint with `N`, and rolls with `R`
- **THEN** each key triggers only its assigned action with no conflict

#### Scenario: Binding written back
- **WHEN** a fresh profile has been played and closed
- **THEN** its `options.txt` still binds Xaero's Minimap new waypoint to `N`

### Requirement: Client memory guidance
Players SHALL be told, in the play guide, to give the game 4 GB of memory at minimum and 6 GB as recommended, and not more than 8 GB.

#### Scenario: Memory section
- **WHEN** a player reads the play guide
- **THEN** it states these limits and where to set them in each launcher the pack install and update guide covers

### Requirement: First-minutes guidance
A play guide (English and matching Traditional Chinese copy) SHALL teach players RPG class spells (Spell Binding Table and Runes), Better Combat and Combat Roll, Traveler's Backpack, Waystones, death graves (You're in Grave Danger), EMI recipe lookup, Farmer's Delight cooking, and End Remastered plus Bosses progression, with a key table. It SHALL link to the install guide for installation and updates.

#### Scenario: New player
- **WHEN** a player reads the first-minutes section and the key table
- **THEN** each step names the key or action it uses, matching the key bindings above

#### Scenario: Player who has not installed the pack
- **WHEN** a player opens the play guide first
- **THEN** it sends them to the pack install and update guide and explains none of its steps itself

### Requirement: Gameplay acceptance checklist
The gameplay items of the player acceptance run that `compose-services` defines SHALL be: Better Combat melee swing and Combat Roll dodge, RPG Series spell binding and casting, custom dungeon/structure exploration (Dungeons & Taverns, Towns & Towers, or YUNG's), Waystone activation and teleportation, Traveler's Backpack equip and storage, death grave creation and recovery (You're in Grave Danger), and Farmer's Delight cooking pot crafting.

#### Scenario: Release sign-off
- **WHEN** a branch that changes the pack or the stack is accepted, which releases it
- **THEN** all seven gameplay items pass on staging before the merge and on production after the deployment

### Requirement: Game troubleshooting
The play guide SHALL tell players what to do when the game crashes while loading, when the frame rate is low (including when shaders are enabled via Iris), and when spells or RPG abilities do not cast.

#### Scenario: Low frame rate
- **WHEN** a player's frame rate is low with the pack's defaults
- **THEN** the play guide tells them to disable Iris shaders if enabled, and lower the render distance to 8 and the simulation distance to 5

#### Scenario: Crash while loading
- **WHEN** the game crashes while loading
- **THEN** the play guide tells the player to verify Java 21, set maximum memory to the recommended 6 GB, and update their graphics driver

### Requirement: Pack identity
The pack SHALL be named `MMC3 Pack`. Its published file SHALL have the base name `mmc3`; `mrpack-distribution` and `compose-services` write that name as `<pack>` in `dist/<pack>.mrpack` and `dist/<pack>.env`. A server whose deployer supplies no display name SHALL be called `MMC3 Server`.

#### Scenario: Pack name
- **WHEN** the pack is exported
- **THEN** its index carries the name `MMC3 Pack`

#### Scenario: Published file names
- **WHEN** the pack is published
- **THEN** the files are `dist/mmc3.mrpack` and `dist/mmc3.env`

#### Scenario: Default display name
- **WHEN** no display name is supplied
- **THEN** the MOTD starts with `MMC3 Server`
