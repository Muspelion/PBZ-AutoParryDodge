# PBZ Auto Parry & Dodge

**🇬🇧 English** · [🇵🇱 Polski](README.pl.md) · [🇫🇷 Français](README.fr.md) · [🇪🇸 Español](README.es.md) · [🇺🇦 Українська](README.uk.md)

An accessibility mod for **Phantom Blade Zero** (PC) that performs **perfect parries and perfect dodges for you**,
against every enemy and boss.

> ♿ **This mod was created with players with motor disabilities in mind.** Phantom Blade Zero asks for
> frame-precise button presses (a perfect parry window is 200–333 ms). If your hands, reaction time or
> controller setup make that hard or impossible, this mod takes over the timing so you can still enjoy the
> combat and the story.

> ⚠️ **An official, legally purchased version of the game is required for the mod to work.**

---

## ✨ What it does

- **Automatic perfect parry** – every melee hit and every enemy projectile (rocks, arrows, bullets) is
  parried inside the *perfect* window. Perfect parries also damage the enemy's posture (Shachi).
- **Automatic perfect dodge** – attacks that cannot be parried (red-eye attacks, grabs) are dodged with a
  perfect dodge instead.
- **Smart mode** – the mod chooses parry or dodge for each attack, the same way the game classifies it.
- **Works on all enemies and bosses**, on every difficulty.
- **On-screen status** – after loading a save and whenever you change a setting, a short message shows what is on.
- **Your settings are remembered** between game sessions.
- **Nothing in the game is modified** – the mod only adds files next to the game; uninstalling restores the original folder.

### Tested results

| Situation (Easy difficulty, Steam version) | Automatic parries / dodges | HP lost on those attacks |
|---|---|---|
| Regular enemies (melee + thrown rocks) | 18 | 0 |
| Boss fight | 45 | 0 |

## 📋 Requirements

- An **official copy** of Phantom Blade Zero for PC (Windows 10/11).
  - **Steam** – tested ✅
  - **Epic Games Store** – supported by the installer, not tested yet
  - **GOG** – the game is not on GOG at the moment; the installer will find it if it appears there
- An internet connection for the first installation (the installer downloads
  [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), the free mod loader for Unreal Engine games).
- The game is **single-player only** and has no anti-cheat. This mod does not touch DRM or online features.

## 🚀 Easy installation (recommended)

1. Download **`PBZ-AutoParryDodge-v1.0.0.zip`** from the [**Releases**](../../releases/latest) page.
2. Unpack the zip anywhere (for example on the Desktop).
3. **Close the game.**
4. Double-click **`install.bat`**.
   - If Windows shows *“Windows protected your PC”*, click **More info → Run anyway**
     (the installer is a plain text script – you can open `install.ps1` in Notepad to read it).
5. The installer finds the game, installs UE4SS if needed, and adds the mod. When it says **Done!**, close the window.
6. Start the game normally. After loading a save you will see:
   `Auto Parry: ON | Auto Dodge: ON | Mode: SMART (parry + dodge)`

If the game is not found automatically, the installer asks for the game folder:
Steam → right-click Phantom Blade Zero → **Manage → Browse local files**;
Epic → Library → **⋯ → Manage → Installation folder**. Copy that path and paste it into the installer window.

## 🎮 Controls

| Key | Action |
|---|---|
| **F7** | Auto parry ON / OFF |
| **F8** | Auto dodge ON / OFF |
| **F9** | Mode: **SMART** (parry + dodge) → **PARRY ONLY** → **DODGE ONLY** |

Every change is shown on screen for 3 seconds and saved automatically.
You can still parry, dodge and attack by yourself at any time – the mod only adds its own presses.

## 🗑️ Uninstall

Close the game and double-click **`uninstall.bat`**. It removes the mod and asks whether to remove UE4SS too
(only if UE4SS was installed by this installer). Answer **y** to restore the game folder to its original state.

## 🔧 Manual installation (advanced)

1. Open the game folder that contains the large `PBZ.exe` (Steam: `…\steamapps\common\PBZ\platform\steam\`).
2. Download the latest `UE4SS_v…zip` (not `zDEV-…`) from
   [UE4SS experimental-latest](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)
   and unpack it there, so that `dwmapi.dll` and the `ue4ss` folder sit next to `PBZ.exe`.
3. Copy the contents of this package's `ue4ss-config` folder into that `ue4ss` folder
   (`MemberVariableLayout.ini` and the `UE4SS_Signatures` folder). The game needs this config to run UE4SS.
4. Copy the `mod\PBZAutoCombat` folder into `ue4ss\Mods\`.
5. Open `ue4ss\Mods\mods.txt` and add the line `PBZAutoCombat : 1` above the `Keybinds` line.
   We recommend setting the other mods in that file to `0` (`Keybinds : 0` too).

## ❓ Troubleshooting

- **The game does not start or crashes at start-up** → run `uninstall.bat` (or delete `dwmapi.dll` next to
  `PBZ.exe`). A game update can change the code that UE4SS needs; check this page for an updated version.
- **No status message after loading a save** → check that `ue4ss\Mods\mods.txt` contains `PBZAutoCombat : 1`
  and look at `ue4ss\UE4SS.log` for errors.
- **Something gets through** → open `ue4ss\Mods\PBZAutoCombat\Scripts\main.lua` in Notepad, change
  `log = false` to `log = true`, play, and attach `autocombat.log` (from the mod folder) to an
  [issue](../../issues). Tell us which enemy and which attack.

## ⚙️ How it works (short)

In Phantom Blade Zero every attacker announces each hit to the defender a fraction of a second in advance,
including the exact time of impact and whether the attack must be dodged. The mod reads these announcements
once per frame and presses parry (or perfect dodge) at the right moment using the game's own input functions.
Enemy projectiles are tracked in flight and their arrival time is predicted from their speed and direction.
The mod is a [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) Lua script; it ships no game files.

## 🙏 Credits

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) – the Unreal Engine scripting system (MIT).
- Phantom Blade Zero UE4SS config (`MemberVariableLayout.ini`, signatures) –
  [KintaroModding](https://github.com/KintaroModding), submitted as
  [UE4SS-RE/RE-UE4SS#1484](https://github.com/UE4SS-RE/RE-UE4SS/pull/1484); signature patterns from the UE4SS
  team's custom game configs (MIT).
- Built with the help of **Claude Code** (Anthropic's Claude AI), which analysed the game's combat logic and wrote
  the mod together with the author; all results were tested in the real game.

## 📄 License & disclaimer

Code: [MIT License](LICENSE). This is an unofficial fan project, not affiliated with or endorsed by S-GAME.
Phantom Blade Zero is a trademark of S-GAME. Use at your own risk – keep a backup of your save files.

See the [changelog](CHANGELOG.md) for version history.
