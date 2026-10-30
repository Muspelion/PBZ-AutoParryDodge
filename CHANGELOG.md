# Changelog

## v1.0.2 – 2026-10-30

- Uninstaller: UE4SS is no longer removed while another PBZ mod (for example
  [PBZ Auto Weapon Switch](https://github.com/Muspelion/PBZ-AutoWeaponSwitch)) still uses it.

## v1.0.1 – 2026-10-30

- Fixed: the mod could follow the wrong character in chapters that keep several player characters in the level
  (for example the prologue climax fight), so nothing was parried or dodged. It now uses the character you control.
- Better parrying of fast flurries: the stance is kept up between closely spaced hits instead of being released and
  pressed again, and every hit still gets its own perfect window.
- Attacks the game withdraws and re-announces right before they land are now parried on time.
- Wide projectiles (waves, sword slashes) are detected from further away.
- Log (`log = true`): every HP loss is written once, with the enemy animation that caused it.

## v1.0.0 – 2026-10-29

First public release.

- Automatic perfect parry for melee attacks and enemy projectiles (predicted from flight path).
- Automatic perfect dodge for attacks the game marks as "must dodge" (red-eye attacks, grabs).
- Smart mode (parry or dodge per attack), parry-only and dodge-only modes.
- F7 / F8 / F9 toggles with an on-screen status message; settings saved in `settings.txt`.
- One-click installer and uninstaller (Steam; Epic Games Store and GOG detection).
- Tested on Phantom Blade Zero `CL-301524_JKS-17219` (Steam build 26266538) with UE4SS `v3.0.1-1185` experimental.
