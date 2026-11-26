# Play Guide

*(繁體中文版本：[docs/play-guide.zh-TW.md](play-guide.zh-TW.md))*

> **Haven't installed the pack yet?** Follow the [Pack Install and Update Guide](pack-install-guide.md) first, then come back here before your first launch.

## What your PC needs

- **Java 21** (Minecraft 1.21.1 and Fabric 0.20.1 require Java 21; both Modrinth App and Prism Launcher can download Java 21 automatically).
- At least **8 GB of system RAM** (16 GB recommended if running shaders with Iris).

## Give the game enough memory

Allocate **4 GB minimum**, **6 GB recommended**, and **no more than 8 GB** to Minecraft (allocating more than 8 GB often causes longer garbage-collection lag spikes).

- **Modrinth App**: Open the instance → **Settings** (gear icon) → **Java and memory** → enable **Custom memory allocation** → set to **6144 MB** (6 GB; or **4096 MB** on an 8 GB PC), and confirm Java version is **Java 21**.
- **Prism Launcher**: Select the instance → **Edit** → **Settings** → **Java** → enable **Memory** → set **Minimum** to `2048 MiB` and **Maximum** to `6144 MiB` (`4096 MiB` on an 8 GB PC), and select a **Java 21** installation.

## Your first minutes in the game

1. **Check recipes anytime with EMI**: Open your inventory (`E`) and use the **EMI** search bar on the right to search any item, weapon, armor, or spell book, click an item for its recipe, and press `U` over an item to see its uses.
2. **Try Better Combat & Combat Roll**: Craft your first melee weapon (swords, spears, axes, daggers, claymores) — **Better Combat** gives realistic sweep combos, and pressing **`R`** performs a **Combat Roll** dodge.
3. **Choose an RPG class path (RPG Series + Spell Engine)**:
   - Craft a **Spell Binding Table** and **Runes** (look up recipes in EMI) to bind spells to class Spell Books:
     - **Wizards**: Fire, Frost, and Arcane staves & robes
     - **Paladins & Priests**: Shields, maces, holy healing & protection spells
     - **Archers**: Longbows, crossbows, and ranged combat skills
     - **Rogues & Warriors**: Daggers, sickles, stealth, and melee skills
   - Keep the required **Runes** in your inventory to cast spells, and equip **Jewelry** / **Relics** in your Trinkets slots for passive bonuses.
4. **Gear up for exploration**:
   - Craft a **Traveler's Backpack**, equip it on your back, and open it anytime with **`B`**.
   - Activate **Waystones** in villages (`Towns and Towers`) or craft your own to fast-travel between party bases and dungeons.
   - Cook hearty medieval meals with **Farmer's Delight** (Cooking Pot over a campfire/stove) for stronger saturation and nourishment buffs.
5. **Explore dungeons & progress to endgame**:
   - Raid overhauled structures from **Dungeons and Taverns**, **YUNG's Better Dungeons**, **Better Nether Fortresses**, and **Better Strongholds**.
   - If you die, **You're in Grave Danger** safely stores your gear inside a grave at your death location — walk back and interact with your grave to recover everything.
   - Instead of vanilla Eyes of Ender, **End Remastered** requires collecting **12 unique Eyes** from dungeons, bosses, and structures to unlock the End, and **Bosses of Mass Destruction** adds four major bosses (Night Lich, Void Blossom, Nether Gauntlet, and Obsidilith) to challenge with your party.

## Keys worth knowing

| Key | Action | Mod |
|---|---|---|
| `B` | Open Traveler's Backpack | Traveler's Backpack |
| `N` | Create New Waypoint *(moved from `B` to avoid backpack conflict)* | Xaero's Minimap |
| `M` | Open Fullscreen World Map | Xaero's World Map |
| `R` | Combat Roll dodge | Combat Roll |
| `E` | Inventory & EMI recipe search | Minecraft / EMI |
| `U` | Show item uses (hover in EMI) | EMI |

## Troubleshooting

- **Game crashes while loading**:
  1. Confirm the profile is using **Java 21** (older Java versions cannot launch Minecraft 1.21.1).
  2. Set maximum memory to the recommended **6 GB** (`6144 MB`).
  3. Update your GPU drivers (NVIDIA, AMD, or Intel).
- **Low frame rate (FPS)**:
  1. If you enabled a shader pack via **Iris Shaders**, disable shaders or switch to a lighter shader profile.
  2. Lower **Render Distance** from `10` to `8` and **Simulation Distance** from `6` to `5` in Video Settings.
  3. Keep maximum memory at `6 GB` (not above `8 GB`).
- **Spells or RPG abilities do not cast**:
  1. Confirm you bound spells onto your Spell Book at a **Spell Binding Table** and are holding a compatible class weapon/staff.
  2. Confirm you have the required **Runes** in your inventory.
  3. Check **Options → Controls → Key Binds** under *Spell Engine* and *Combat Roll* to make sure no custom key conflicts were introduced.
