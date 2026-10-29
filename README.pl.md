# PBZ Auto Parry & Dodge

[🇬🇧 English](README.md) · **🇵🇱 Polski** · [🇫🇷 Français](README.fr.md) · [🇪🇸 Español](README.es.md) · [🇺🇦 Українська](README.uk.md)

Mod ułatwień dostępu do gry **Phantom Blade Zero** (PC), który **sam wykonuje perfekcyjne parowania
i perfekcyjne uniki** przeciwko wszystkim przeciwnikom i bossom.

> ♿ **Mod został stworzony z myślą o osobach z niepełnosprawnością ruchową.** Phantom Blade Zero wymaga
> wciskania przycisków co do klatki (okno perfekcyjnego parowania trwa 200–333 ms). Jeśli dłonie, czas reakcji
> lub sposób sterowania utrudniają to albo uniemożliwiają, mod przejmuje wyczucie czasu, a Ty możesz cieszyć się
> walką i fabułą.

> ⚠️ **Do działania moda potrzebna jest oficjalna, legalnie kupiona wersja gry.**

---

## ✨ Co robi mod

- **Automatyczne perfekcyjne parowanie** – każdy cios wręcz i każdy pocisk przeciwnika (kamienie, strzały, kule)
  jest parowany w oknie *perfect*. Perfekcyjne parowanie dodatkowo osłabia postawę wroga (Shachi).
- **Automatyczny perfekcyjny unik** – ataki, których nie da się sparować (atak z czerwonym okiem, chwyty),
  są omijane perfekcyjnym unikiem.
- **Tryb inteligentny (SMART)** – mod dla każdego ataku wybiera parowanie albo unik, tak jak klasyfikuje go gra.
- **Działa na wszystkich przeciwników i bossów**, na każdym poziomie trudności.
- **Komunikat na ekranie** – po wczytaniu zapisu i przy każdej zmianie ustawień krótki komunikat pokazuje, co jest włączone.
- **Ustawienia są zapamiętywane** między uruchomieniami gry.
- **Gra nie jest modyfikowana** – mod tylko dodaje pliki obok gry; odinstalowanie przywraca oryginalny folder.

### Wyniki testów

| Sytuacja (poziom Easy, wersja Steam) | Automatyczne parowania / uniki | Utrata HP przy tych atakach |
|---|---|---|
| Zwykli przeciwnicy (wręcz + rzucane kamienie) | 18 | 0 |
| Walka z bossem | 45 | 0 |

## 📋 Wymagania

- **Oficjalna wersja** Phantom Blade Zero na PC (Windows 10/11).
  - **Steam** – przetestowane ✅
  - **Epic Games Store** – obsługiwane przez instalator, jeszcze nieprzetestowane
  - **GOG** – gry obecnie nie ma na GOG; jeśli się pojawi, instalator ją znajdzie
- Połączenie z internetem przy pierwszej instalacji (instalator pobiera
  [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) – darmowy loader modów do gier na Unreal Engine).
- Gra jest **wyłącznie dla jednego gracza** i nie ma anty-cheata. Mod nie dotyka zabezpieczeń DRM ani funkcji online.

## 🚀 Łatwa instalacja (zalecana)

1. Pobierz **`PBZ-AutoParryDodge-v1.0.0.zip`** ze strony [**Releases**](../../releases/latest).
2. Rozpakuj archiwum w dowolnym miejscu (np. na Pulpicie).
3. **Zamknij grę.**
4. Kliknij dwukrotnie **`install.bat`**.
   - Jeśli Windows pokaże *„System Windows ochronił ten komputer”*, kliknij **Więcej informacji → Uruchom mimo to**
     (instalator to zwykły skrypt tekstowy – możesz otworzyć `install.ps1` w Notatniku i go przeczytać).
5. Instalator sam znajdzie grę, w razie potrzeby zainstaluje UE4SS i doda mod. Gdy wyświetli **Done!**, zamknij okno.
6. Uruchom grę normalnie. Po wczytaniu zapisu zobaczysz:
   `Auto Parry: ON | Auto Dodge: ON | Mode: SMART (parry + dodge)`

Jeśli gra nie zostanie znaleziona automatycznie, instalator zapyta o folder gry:
Steam → prawy przycisk na Phantom Blade Zero → **Zarządzaj → Przeglądaj pliki lokalne**;
Epic → Biblioteka → **⋯ → Zarządzaj → Folder instalacji**. Skopiuj tę ścieżkę i wklej ją w oknie instalatora.

## 🎮 Sterowanie

| Klawisz | Działanie |
|---|---|
| **F7** | Auto parowanie WŁ. / WYŁ. |
| **F8** | Auto unik WŁ. / WYŁ. |
| **F9** | Tryb: **SMART** (parowanie + unik) → **PARRY ONLY** (tylko parowanie) → **DODGE ONLY** (tylko unik) |

Każda zmiana pojawia się na ekranie na 3 sekundy i jest zapisywana automatycznie.
Nadal możesz w każdej chwili sam parować, robić uniki i atakować – mod tylko dodaje własne naciśnięcia.

## 🗑️ Odinstalowanie

Zamknij grę i kliknij dwukrotnie **`uninstall.bat`**. Usuwa mod i pyta, czy usunąć także UE4SS
(tylko jeśli UE4SS zainstalował ten instalator). Odpowiedz **y**, aby przywrócić folder gry do stanu oryginalnego.

## 🔧 Instalacja ręczna (dla zaawansowanych)

1. Otwórz folder gry z dużym plikiem `PBZ.exe` (Steam: `…\steamapps\common\PBZ\platform\steam\`).
2. Pobierz najnowszy `UE4SS_v…zip` (nie `zDEV-…`) ze strony
   [UE4SS experimental-latest](https://github.com/UE4SS-RE/RE-UE4SS/releases/tag/experimental-latest)
   i rozpakuj go tam tak, aby `dwmapi.dll` i folder `ue4ss` leżały obok `PBZ.exe`.
3. Skopiuj zawartość folderu `ue4ss-config` z tej paczki do folderu `ue4ss`
   (`MemberVariableLayout.ini` i folder `UE4SS_Signatures`). Bez tej konfiguracji UE4SS nie zadziała w tej grze.
4. Skopiuj folder `mod\PBZAutoCombat` do `ue4ss\Mods\`.
5. Otwórz `ue4ss\Mods\mods.txt` i dodaj linię `PBZAutoCombat : 1` nad linią `Keybinds`.
   Zalecamy ustawić pozostałe mody w tym pliku na `0` (również `Keybinds : 0`).

## ❓ Rozwiązywanie problemów

- **Gra się nie uruchamia albo wyłącza przy starcie** → uruchom `uninstall.bat` (albo usuń `dwmapi.dll` obok
  `PBZ.exe`). Aktualizacja gry może zmienić kod potrzebny UE4SS – sprawdź tę stronę, czy jest nowa wersja.
- **Brak komunikatu po wczytaniu zapisu** → sprawdź, czy `ue4ss\Mods\mods.txt` zawiera `PBZAutoCombat : 1`,
  i poszukaj błędów w `ue4ss\UE4SS.log`.
- **Jakiś atak przechodzi** → otwórz `ue4ss\Mods\PBZAutoCombat\Scripts\main.lua` w Notatniku, zmień
  `log = false` na `log = true`, zagraj i dołącz plik `autocombat.log` (z folderu moda) do
  [zgłoszenia](../../issues). Napisz, który przeciwnik i który atak.

## ⚙️ Jak to działa (w skrócie)

W Phantom Blade Zero każdy atakujący zapowiada obrońcy każdy cios ułamek sekundy wcześniej – z dokładnym czasem
trafienia i informacją, czy trzeba go uniknąć. Mod co klatkę czyta te zapowiedzi i we właściwym momencie wciska
parowanie (albo perfekcyjny unik) za pomocą funkcji wejścia samej gry. Pociski wroga są śledzone w locie,
a czas ich dolotu jest przewidywany z prędkości i kierunku. Mod to skrypt Lua dla
[UE4SS](https://github.com/UE4SS-RE/RE-UE4SS); nie zawiera żadnych plików gry.

## 🙏 Podziękowania

- [UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) – system skryptów dla Unreal Engine (MIT).
- Konfiguracja UE4SS dla Phantom Blade Zero (`MemberVariableLayout.ini`, sygnatury) –
  [KintaroModding](https://github.com/KintaroModding), zgłoszona jako
  [UE4SS-RE/RE-UE4SS#1484](https://github.com/UE4SS-RE/RE-UE4SS/pull/1484); wzorce sygnatur z konfiguracji
  zespołu UE4SS (MIT).
- Mod powstał z pomocą **Claude Code** (sztuczna inteligencja Claude firmy Anthropic), która przeanalizowała
  logikę walki w grze i napisała mod razem z autorem; wszystkie wyniki zostały sprawdzone w prawdziwej grze.

## 📄 Licencja i zastrzeżenia

Kod: [licencja MIT](LICENSE). To nieoficjalny projekt fanowski, niezwiązany z S-GAME ani przez nią niepopierany.
Phantom Blade Zero jest znakiem towarowym S-GAME. Używasz na własne ryzyko – zrób kopię zapasową zapisów gry.

Historia wersji: [changelog](CHANGELOG.md).
