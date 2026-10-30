# PBZ Auto Parry & Dodge

[🇬🇧 English](README.md) · [🇵🇱 Polski](README.pl.md) · [🇫🇷 Français](README.fr.md) · **🇪🇸 Español** · [🇺🇦 Українська](README.uk.md)

Un mod de accesibilidad para **Phantom Blade Zero** (PC) que **realiza por ti bloqueos perfectos y esquivas
perfectas** contra todos los enemigos y jefes.

> ♿ **Este mod se creó pensando en las personas con discapacidad motora.** Phantom Blade Zero exige pulsar
> botones con precisión de fotograma (la ventana del bloqueo perfecto dura entre 200 y 333 ms). Si tus manos, tu
> tiempo de reacción o tu forma de jugar lo hacen difícil o imposible, el mod se encarga del momento exacto para
> que puedas disfrutar del combate y de la historia.

> ⚠️ **Para que el mod funcione se necesita una versión oficial del juego, comprada legalmente.**

---

## ✨ Qué hace

- **Bloqueo perfecto automático** – cada golpe cuerpo a cuerpo y cada proyectil enemigo (piedras, flechas, balas)
  se bloquea dentro de la ventana *perfecta*. Los bloqueos perfectos además rompen la postura del enemigo (Shachi).
- **Esquiva perfecta automática** – los ataques que no se pueden bloquear (ataques de «ojo rojo», agarres)
  se evitan con una esquiva perfecta.
- **Modo inteligente (SMART)** – el mod elige bloqueo o esquiva para cada ataque, igual que lo clasifica el juego.
- **Funciona contra todos los enemigos y jefes**, en cualquier dificultad.
- **Estado en pantalla** – tras cargar una partida y cada vez que cambias un ajuste aparece un mensaje breve.
- **Tus ajustes se recuerdan** entre sesiones de juego.
- **No se modifica el juego** – el mod solo añade archivos junto al juego; al desinstalarlo, la carpeta vuelve a su estado original.

### Resultados de las pruebas

| Situación (dificultad Easy, versión Steam) | Bloqueos / esquivas automáticos | PV perdidos en esos ataques |
|---|---|---|
| Enemigos normales (cuerpo a cuerpo + piedras lanzadas) | 18 | 0 |
| Combate contra jefe | 45 | 0 |

## 📋 Requisitos

- Una **copia oficial** de Phantom Blade Zero para PC (Windows 10/11).
  - **Steam** – probado ✅
  - **Epic Games Store** – compatible con el instalador, aún sin probar
  - **GOG** – el juego no está en GOG por ahora; si aparece, el instalador lo encontrará
- Conexión a Internet en la primera instalación (el instalador descarga
  [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS), el cargador de mods gratuito para juegos de Unreal Engine).
- El juego es **solo para un jugador** y no tiene antitrampas. El mod no toca el DRM ni las funciones en línea.

## 🚀 Instalación fácil (recomendada)

1. Descarga **`PBZ-AutoParryDodge-v1.1.0.zip`** desde la página [**Releases**](../../releases/latest).
2. Descomprime el archivo donde quieras (por ejemplo, en el Escritorio).
3. **Cierra el juego.**
4. Haz doble clic en **`install.bat`**.
   - Si Windows muestra *«Windows protegió su PC»*, pulsa **Más información → Ejecutar de todas formas**
     (el instalador es un simple script de texto; puedes abrir `install.ps1` con el Bloc de notas para leerlo).
5. El instalador encuentra el juego, instala UE4SS si hace falta y añade el mod. Cuando muestre **Done!**, cierra la ventana.
6. Inicia el juego con normalidad. Tras cargar una partida verás:
   `Auto Parry: ON | Auto Dodge: ON | Mode: SMART (parry + dodge)`

Si el juego no se encuentra automáticamente, el instalador pedirá su carpeta:
Steam → clic derecho en Phantom Blade Zero → **Administrar → Ver archivos locales**;
Epic → Biblioteca → **⋯ → Administrar → Carpeta de instalación**. Copia esa ruta y pégala en la ventana del instalador.

## 🎮 Controles

| Tecla | Acción |
|---|---|
| **F7** | Bloqueo automático ACTIVADO / DESACTIVADO |
| **F8** | Esquiva automática ACTIVADA / DESACTIVADA |
| **F9** | Modo: **SMART** (bloqueo + esquiva) → **PARRY ONLY** (solo bloqueo) → **DODGE ONLY** (solo esquiva) |

Cada cambio se muestra en pantalla durante 3 segundos y se guarda automáticamente.
Puedes seguir bloqueando, esquivando y atacando tú mismo en cualquier momento; el mod solo añade sus propias pulsaciones.

## 🗑️ Desinstalación

Cierra el juego y haz doble clic en **`uninstall.bat`**. Elimina el mod y pregunta si quieres eliminar también UE4SS
(solo si lo instaló este instalador). Responde **y** para devolver la carpeta del juego a su estado original.

## 🔧 Instalación manual (avanzada)

1. Abre la carpeta del juego que contiene el `PBZ.exe` grande (Steam: `…\steamapps\common\PBZ\platform\steam\`).
2. Descarga el último `UE4SS_v…zip` (no `zDEV-…`) desde
   [UE4SS experimental-latest](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)
   y descomprímelo ahí, de modo que `dwmapi.dll` y la carpeta `ue4ss` queden junto a `PBZ.exe`.
3. Copia el contenido de la carpeta `ue4ss-config` de este paquete dentro de la carpeta `ue4ss`
   (`MemberVariableLayout.ini` y la carpeta `UE4SS_Signatures`). El juego la necesita para que UE4SS funcione.
4. Copia la carpeta `mod\PBZAutoCombat` en `ue4ss\Mods\`.
5. Abre `ue4ss\Mods\mods.txt` y añade la línea `PBZAutoCombat : 1` encima de la línea `Keybinds`.
   Recomendamos poner a `0` los demás mods de ese archivo (también `Keybinds : 0`).

## ❓ Solución de problemas

- **El juego no arranca o se cierra al iniciar** → ejecuta `uninstall.bat` (o borra `dwmapi.dll` junto a
  `PBZ.exe`). Una actualización del juego puede cambiar el código que necesita UE4SS; consulta aquí si hay una versión nueva.
- **No aparece el mensaje tras cargar la partida** → comprueba que `ue4ss\Mods\mods.txt` contiene
  `PBZAutoCombat : 1` y busca errores en `ue4ss\UE4SS.log`.
- **Algún ataque se cuela** → abre `ue4ss\Mods\PBZAutoCombat\Scripts\main.lua` con el Bloc de notas, cambia
  `log = false` por `log = true`, juega y adjunta `autocombat.log` (de la carpeta del mod) en un
  [issue](../../issues). Indica qué enemigo y qué ataque.

## ⚙️ Cómo funciona (resumen)

En Phantom Blade Zero cada atacante anuncia cada golpe al defensor una fracción de segundo antes, con el instante
exacto del impacto e indicando si hay que esquivarlo. El mod lee estos anuncios en cada fotograma y pulsa bloqueo
(o esquiva perfecta) en el momento justo usando las funciones de entrada del propio juego. Los proyectiles enemigos
se siguen en vuelo y su llegada se predice a partir de su velocidad y dirección. El mod es un script Lua para
[UE4SS](https://github.com/UE4SS-RE/RE-UE4SS); no incluye ningún archivo del juego.

## 🙏 Créditos

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) – el sistema de scripts para Unreal Engine (MIT).
- Configuración de UE4SS para Phantom Blade Zero (`MemberVariableLayout.ini`, firmas) –
  [KintaroModding](https://github.com/KintaroModding), propuesta en
  [UE4SS-RE/RE-UE4SS#1484](https://github.com/UE4SS-RE/RE-UE4SS/pull/1484); patrones de firmas de las
  configuraciones del equipo de UE4SS (MIT).
- Creado con la ayuda de **Claude Code** (la IA Claude de Anthropic), que analizó la lógica de combate del juego y
  escribió el mod junto con el autor; todos los resultados se comprobaron en el juego real.

## 📄 Licencia y aviso

Código: [licencia MIT](LICENSE). Proyecto no oficial de fans, sin relación con S-GAME ni respaldado por ella.
Phantom Blade Zero es una marca de S-GAME. Úsalo bajo tu responsabilidad y haz copia de tus partidas guardadas.

Historial de versiones: [changelog](CHANGELOG.md).
