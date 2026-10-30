# PBZ Auto Parry & Dodge

[🇬🇧 English](README.md) · [🇵🇱 Polski](README.pl.md) · **🇫🇷 Français** · [🇪🇸 Español](README.es.md) · [🇺🇦 Українська](README.uk.md)

Un mod d'accessibilité pour **Phantom Blade Zero** (PC) qui **effectue pour vous des parades parfaites et des
esquives parfaites**, contre tous les ennemis et tous les boss.

> ♿ **Ce mod a été créé en pensant aux personnes en situation de handicap moteur.** Phantom Blade Zero exige des
> pressions de touches précises à l'image près (la fenêtre de parade parfaite dure 200 à 333 ms). Si vos mains,
> votre temps de réaction ou votre manette rendent cela difficile ou impossible, le mod s'occupe du timing pour
> que vous puissiez profiter des combats et de l'histoire.

> ⚠️ **Une version officielle du jeu, achetée légalement, est nécessaire pour que le mod fonctionne.**

---

## ✨ Ce que fait le mod

- **Parade parfaite automatique** – chaque coup au corps à corps et chaque projectile ennemi (pierres, flèches,
  balles) est paré dans la fenêtre *parfaite*. Les parades parfaites réduisent aussi la posture de l'ennemi (Shachi).
- **Esquive parfaite automatique** – les attaques impossibles à parer (attaques « œil rouge », saisies) sont
  évitées par une esquive parfaite.
- **Mode intelligent (SMART)** – le mod choisit parade ou esquive pour chaque attaque, comme le jeu la classe.
- **Fonctionne contre tous les ennemis et les boss**, à toutes les difficultés.
- **État affiché à l'écran** – après le chargement d'une sauvegarde et à chaque changement de réglage.
- **Vos réglages sont mémorisés** d'une session à l'autre.
- **Le jeu n'est pas modifié** – le mod ajoute seulement des fichiers à côté du jeu ; la désinstallation rétablit le dossier d'origine.

### Résultats des tests

| Situation (difficulté Easy, version Steam) | Parades / esquives automatiques | PV perdus sur ces attaques |
|---|---|---|
| Ennemis normaux (mêlée + pierres lancées) | 18 | 0 |
| Combat de boss | 45 | 0 |

## 📋 Configuration requise

- Une **copie officielle** de Phantom Blade Zero sur PC (Windows 10/11).
  - **Steam** – testé ✅
  - **Epic Games Store** – pris en charge par l'installateur, pas encore testé
  - **GOG** – le jeu n'est pas sur GOG pour l'instant ; l'installateur le trouvera s'il y paraît
- Une connexion Internet lors de la première installation (l'installateur télécharge
  [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), le chargeur de mods gratuit pour les jeux Unreal Engine).
- Le jeu est **uniquement solo** et n'a pas d'anti-triche. Le mod ne touche ni au DRM ni aux fonctions en ligne.

## 🚀 Installation facile (recommandée)

1. Téléchargez **`PBZ-AutoParryDodge-v1.0.1.zip`** depuis la page [**Releases**](../../releases/latest).
2. Décompressez l'archive où vous voulez (par exemple sur le Bureau).
3. **Fermez le jeu.**
4. Double-cliquez sur **`install.bat`**.
   - Si Windows affiche *« Windows a protégé votre ordinateur »*, cliquez sur **Informations complémentaires →
     Exécuter quand même** (l'installateur est un simple script texte – vous pouvez lire `install.ps1` dans le Bloc-notes).
5. L'installateur trouve le jeu, installe UE4SS si nécessaire et ajoute le mod. Quand il affiche **Done!**, fermez la fenêtre.
6. Lancez le jeu normalement. Après le chargement d'une sauvegarde, vous verrez :
   `Auto Parry: ON | Auto Dodge: ON | Mode: SMART (parry + dodge)`

Si le jeu n'est pas trouvé automatiquement, l'installateur demande son dossier :
Steam → clic droit sur Phantom Blade Zero → **Gérer → Parcourir les fichiers locaux** ;
Epic → Bibliothèque → **⋯ → Gérer → Dossier d'installation**. Copiez ce chemin et collez-le dans la fenêtre.

## 🎮 Commandes

| Touche | Action |
|---|---|
| **F7** | Parade auto ACTIVÉE / DÉSACTIVÉE |
| **F8** | Esquive auto ACTIVÉE / DÉSACTIVÉE |
| **F9** | Mode : **SMART** (parade + esquive) → **PARRY ONLY** (parade seule) → **DODGE ONLY** (esquive seule) |

Chaque changement s'affiche 3 secondes et est enregistré automatiquement.
Vous pouvez toujours parer, esquiver et attaquer vous-même – le mod ajoute seulement ses propres appuis.

## 🗑️ Désinstallation

Fermez le jeu et double-cliquez sur **`uninstall.bat`**. Il supprime le mod et demande s'il faut aussi supprimer
UE4SS (seulement si UE4SS a été installé par cet installateur). Répondez **y** pour rétablir le dossier d'origine.

## 🔧 Installation manuelle (avancée)

1. Ouvrez le dossier du jeu qui contient le gros `PBZ.exe` (Steam : `…\steamapps\common\PBZ\platform\steam\`).
2. Téléchargez le dernier `UE4SS_v…zip` (pas `zDEV-…`) depuis
   [UE4SS experimental-latest](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)
   et décompressez-le à cet endroit, pour que `dwmapi.dll` et le dossier `ue4ss` soient à côté de `PBZ.exe`.
3. Copiez le contenu du dossier `ue4ss-config` de ce paquet dans le dossier `ue4ss`
   (`MemberVariableLayout.ini` et le dossier `UE4SS_Signatures`). Le jeu en a besoin pour faire fonctionner UE4SS.
4. Copiez le dossier `mod\PBZAutoCombat` dans `ue4ss\Mods\`.
5. Ouvrez `ue4ss\Mods\mods.txt` et ajoutez la ligne `PBZAutoCombat : 1` au-dessus de la ligne `Keybinds`.
   Nous conseillons de mettre les autres mods de ce fichier à `0` (y compris `Keybinds : 0`).

## ❓ Dépannage

- **Le jeu ne démarre pas ou plante au lancement** → lancez `uninstall.bat` (ou supprimez `dwmapi.dll` à côté
  de `PBZ.exe`). Une mise à jour du jeu peut changer le code dont UE4SS a besoin ; vérifiez s'il existe une nouvelle version ici.
- **Aucun message après le chargement** → vérifiez que `ue4ss\Mods\mods.txt` contient `PBZAutoCombat : 1`
  et cherchez des erreurs dans `ue4ss\UE4SS.log`.
- **Une attaque passe** → ouvrez `ue4ss\Mods\PBZAutoCombat\Scripts\main.lua` dans le Bloc-notes, remplacez
  `log = false` par `log = true`, jouez, puis joignez `autocombat.log` (dans le dossier du mod) à une
  [issue](../../issues). Précisez l'ennemi et l'attaque.

## ⚙️ Fonctionnement (en bref)

Dans Phantom Blade Zero, chaque attaquant annonce chaque coup au défenseur une fraction de seconde à l'avance,
avec l'instant exact de l'impact et l'indication s'il faut l'esquiver. Le mod lit ces annonces à chaque image et
appuie sur parade (ou esquive parfaite) au bon moment avec les fonctions d'entrée du jeu lui-même. Les projectiles
ennemis sont suivis en vol et leur heure d'arrivée est prédite à partir de leur vitesse et de leur direction.
Le mod est un script Lua pour [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) ; il ne contient aucun fichier du jeu.

## 🙏 Remerciements

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) – le système de scripts pour Unreal Engine (MIT).
- Configuration UE4SS pour Phantom Blade Zero (`MemberVariableLayout.ini`, signatures) –
  [KintaroModding](https://github.com/KintaroModding), proposée dans
  [UE4SS-RE/RE-UE4SS#1484](https://github.com/UE4SS-RE/RE-UE4SS/pull/1484) ; motifs de signatures issus des
  configurations de l'équipe UE4SS (MIT).
- Réalisé avec l'aide de **Claude Code** (l'IA Claude d'Anthropic), qui a analysé la logique de combat du jeu et
  écrit le mod avec l'auteur ; tous les résultats ont été vérifiés dans le vrai jeu.

## 📄 Licence et avertissement

Code : [licence MIT](LICENSE). Projet de fan non officiel, sans lien avec S-GAME ni approuvé par elle.
Phantom Blade Zero est une marque de S-GAME. Utilisation à vos risques – sauvegardez vos fichiers de sauvegarde.

Historique des versions : [changelog](CHANGELOG.md).
