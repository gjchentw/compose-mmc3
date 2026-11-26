# Pack Install and Update Guide

*(繁體中文版本：[docs/pack-install-guide.zh-TW.md](pack-install-guide.zh-TW.md))*

This guide covers downloading, installing, joining, and updating the server's `.mrpack`. For memory limits, key bindings, and in-game tips, see the [Play Guide](play-guide.md).

## What you need

- An official **Minecraft: Java Edition** account (whitelisted by the server administrator).
- Either **Modrinth App** or **Prism Launcher** installed on your computer.
- The fixed `.mrpack` download link sent by your server administrator.
- Confirm your PC meets the requirements in [Play Guide — What your PC needs](play-guide.md#what-your-pc-needs).

## 1. Download the pack

Open the fixed download link provided by your server administrator (it ends in `/dist/mmc3.mrpack`) and save the `.mrpack` file to your computer.

## 2. Install the pack

### Option A: Modrinth App

1. Open **Modrinth App** and sign in with your Microsoft / Minecraft account.
2. Click the **+** (Create new instance) button in the left sidebar.
3. Choose **Import from file** and select the downloaded `mmc3.mrpack`.
4. Wait for Modrinth App to download the loader and mods into the new profile.

### Option B: Prism Launcher

1. Open **Prism Launcher** and sign in with your Microsoft / Minecraft account.
2. Click **Add Instance** → **Import** → **Browse**, and select the downloaded `mmc3.mrpack`.
3. Click **OK** and wait for Prism Launcher to finish downloading the loader and mods.

## 3. Set the game's memory

Before launching for the first time, set the profile's Java memory allocation according to [Play Guide — Give the game enough memory](play-guide.md#give-the-game-enough-memory).

## 4. Join the server

1. Launch the installed profile.
2. Open **Multiplayer**.
3. The server entry is already pre-filled as **`<Server Name> (<pack version>)`** — select it and click **Join Server**.
4. Once in-game, see [Play Guide — Your first minutes in the game](play-guide.md#your-first-minutes-in-the-game).

## Updating the pack

Check the Multiplayer screen before joining:

- Your pre-filled entry name shows the pack version you installed: `<Server Name> (<your version>)`.
- The server's MOTD line underneath shows the version the server is currently running: `<Server Name> | Pack <server version>`.

Whenever those two versions differ:

1. Download the `.mrpack` again from the **same fixed link** your administrator gave you.
2. Install it as a **new profile** in Modrinth App or Prism Launcher (repeat steps 2–3 above).
3. Launch the new profile and join. **All of your character progress, builds, and items live on the server**, so installing a new profile never loses your world progress.
4. Once you confirm the new profile joins cleanly, you may delete the old profile from your launcher.

## Troubleshooting

- **"You are not white-listed on this server"**: Send your exact Minecraft username to the server administrator so they can add you to the whitelist.
- **"Outdated client" / mod mismatch error on join**: Compare the version in your entry name against `Pack <version>` in the server MOTD and follow [Updating the pack](#updating-the-pack).
- **"Failed to verify username" / authentication error**: Sign out and sign back in to your Microsoft account in your launcher, then restart the game.
- **Cannot connect / timed out**: Verify you installed the latest `.mrpack` from the administrator's link (so `servers.dat` has the current address) and confirm with the administrator that the server is online.
- **Crashes during loading or low frame rate**: See [Play Guide — Troubleshooting](play-guide.md#troubleshooting).
