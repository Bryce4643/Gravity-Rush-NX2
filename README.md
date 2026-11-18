# Gravity Rush for Nintendo Switch 2 (Based on Vita3K-nx port)

A dedicated Switch 2 homebrew build of the [Vita3K](https://vita3k.org) PlayStation Vita emulator,
based on [Vita3K-nx](https://github.com/NaGaa95/Vita3K-nx) (the Switch 1 port) and tuned to run
**Gravity Rush (USA, PCSA00011)**. It boots straight into the game: there is no launcher or game list.

It runs on a Switch 2 with **kaiHEN** and the homebrew menu, and is built with the **ounce-devkit**
(libounce, OunceVK Vulkan driver).

> **No game, firmware or Lossless Scaling files are included.** You need your own copy of Gravity
> Rush, the PS Vita firmware, and (optionally) your own copy of Lossless Scaling for frame generation.

---

## What to expect

- **Playable** from start to gameplay, docked and with a Pro Controller (the tested setup).
- **Resolution:** 2× the Vita's native resolution by default.
- **Frame rate:** the game runs at its native **30 FPS**. Gravity Rush's game logic is tied to 30 FPS,
  so "60 FPS" hacks make the whole game run at double speed. For smoother motion, use
  **frame generation** (optional, see below), which shows ~60 FPS at normal game speed.
- **Audio** works (native Switch audio).
- **Touch and motion controls** are mapped to the controller (see [Controls](#controls)).
- **DLC** works if installed.
- **First launch** of an area can stutter briefly while shaders compile; they are cached afterwards.
- **Saves** are Vita3K saves, stored on the SD card. Saves exported from a real Vita are
  **encrypted** (for example, saves from the Apollo save database) and cannot be used unless they were
  exported decrypted from a hacked Vita (VitaShell "Open decrypted" or Apollo on the Vita).

### Known limitations
- Frame generation can ghost around fast-moving objects, and around HUD/text during fast camera
  turns. That is inherent to frame generation.
- Handheld mode has the real touchscreen and the console's own motion sensors, but handheld play has
  had less testing than docked play.
- The motion-control axes were tuned for a Pro Controller. Joy-Cons can be adjusted with `motion.txt`
  (see [Configuration](#configuration)).

---

## Requirements

1. A Nintendo Switch 2 running **kaiHEN** with the **homebrew menu** (hbmenu).
2. An SD card with ~2 GB free.
3. A PC with **[Vita3K](https://vita3k.org)** (Windows, Linux or macOS) to install the game and
   firmware. The Switch build reads the files Vita3K installs.
4. Your own **Gravity Rush (USA) PCSA00011** package and license (and DLC, if you have it).
5. The **PS Vita firmware** update file (`PSVUPDAT.PUP`).
6. *(Optional)* **Lossless Scaling** from Steam, for frame generation.

---

## Installation

### 1. Install the firmware and the game with Vita3K on a PC
1. Run Vita3K on your PC and install the firmware (`PSVUPDAT.PUP`) when it asks.
   Installing the optional firmware **font package** too is recommended.
2. Install Gravity Rush (PCSA00011) with its license, and any DLC.
3. Start the game once on the PC to make sure it works.
4. Find Vita3K's **file system folder**: *Configuration → Settings → Emulator → Emulated system
   storage folder*. It contains `ux0`, `vs0`, `os0`, `sa0` and more.

### 2. Copy everything to the SD card
Use a card reader or FTP. The layout on the SD card must be:

```
sdmc:/switch/gravityrush/
├── GravityRush.nro          ← from the release zip
├── fs/                      ← the CONTENTS of Vita3K's file system folder
│   ├── ux0/
│   │   ├── app/PCSA00011/       (the game: eboot.bin, Gravite.psarc, sce_sys, ...)
│   │   ├── addcont/PCSA00011/   (DLC, optional)
│   │   ├── license/             (licenses)
│   │   └── user/00/savedata/    (saves, created by the game)
│   ├── vs0/  os0/  sa0/ ...     (firmware, from the firmware install)
└── lsfg/                    ← optional, for frame generation
    └── Lossless.dll
```

The build creates `config/`, `cache/`, logs and so on itself on first launch.

> **Check your copy.** The game must be copied completely and undamaged. In particular,
> `ux0/app/PCSA00011/Gravite.psarc` is about 1.4 GB, and `ux0/app/PCSA00011/args.txt` contains
> `-region A`. A damaged `Gravite.psarc` makes the game **hang on the Gravity Rush logo**. If that
> happens, copy the game folder again from the PC where it works, and compare checksums.

### 3. Launch
Open the homebrew menu and start **Gravity Rush**. If the game is missing, the build shows a
"not installed" screen with the path it expected.

To update the build later, replace only `GravityRush.nro`. Your config, saves and game files stay.

---

## Controls

### Buttons (Pro Controller or Joy-Cons)
| Switch | PS Vita |
|---|---|
| A / B / X / Y | Circle / Cross / Triangle / Square (positional, like the Vita) |
| L / R | L / R |
| + / − | Start / Select |
| D-pad | D-pad |
| Left stick / Right stick | Left stick / Right stick |
| Motion (gyro) | Vita motion sensor (aiming, camera) |

### Touch and motion replacements (for docked play)
| Input | Does |
|---|---|
| **ZR + left stick direction** | **Evade:** swipes the touchscreen up, down, left or right. |
| **Hold ZL + ZR** | **Slide:** two fingers held on the touchscreen. |
| **R3** (click the right stick) | Shows a **touch cursor**. Aim it with the right stick (the camera ignores the stick meanwhile). **Click R3 again** to tap. Hold R3 to keep the finger down and move the stick to drag. Releasing hides the cursor. |
| **L3** (click the left stick) | **Recenter motion:** clears gyro drift and resets the facing direction to how you hold the controller now. |
| **L + R + +** | Opens / closes the **quick menu**. |

In handheld mode the real touchscreen also works.

### Quick menu (L + R + +)
The game pauses while the menu is open.

| Entry | Does |
|---|---|
| Resume game | Closes the menu. |
| Frame generation: On / Off | Turns frame generation on or off now. It shows *unavailable* when frame generation is off in Settings, or `Lossless.dll` is missing or the wrong version. |
| Virtual mouse: On / Off | An always-on touch pointer: the left stick moves it and A / B tap. The R3 cursor above is usually quicker. |
| Trophies | Trophy list and progress. |
| Cheats | Toggles installed cheats, if any. |
| Settings | See below. |
| Return to homebrew menu / Quit game | Ends the game and returns to the homebrew menu. |

**Settings** (Left / Right to change). Changes apply immediately for this session, except
*Frame generation*, which is saved and applies from the next launch:
- **Screen filter:** the upscaling filter.
- **VSync**, **Stretch to screen**.
- **FPS hack:** makes Gravity Rush run at **double speed**. Leave it off.
- **Disable surface sync:** a speed/accuracy trade-off. Leave it off unless you're troubleshooting.
- **Audio volume**.
- **Performance overlay**, **Overlay detail**, **Overlay position:** the on-screen FPS counter.
- **Frame generation (next launch):** see below.

---

## Frame generation (optional, ~60 FPS look)

Frame generation inserts generated frames between the game's real 30 FPS frames (LSFG, the technique
from Lossless Scaling, via [lsfg-vk](https://github.com/PancakeTAS/lsfg-vk)). It is **off by default**,
and it needs **your own** copy of Lossless Scaling:

1. In Steam, right-click **Lossless Scaling** → **Properties** → **Betas**, and select the
   **`lsfg-vk`** branch. Let it update. *(The normal release stores its shaders differently and does
   not work. The quick menu then shows "unavailable".)*
2. Copy `Lossless.dll` from the Lossless Scaling install folder to
   `sdmc:/switch/gravityrush/lsfg/Lossless.dll`.
3. Start the game, open the quick menu → **Settings** → set **Frame generation (next launch)** to **On**.
4. Restart the game. Frame generation starts automatically from then on, and the quick menu entry
   can turn it off for the session.

The FPS counter may keep showing 30 (the game's own frames), but motion is visibly smoother.
Quality settings are in `config/config.yml`:
`switch-lsfg-flow-scale: 0.5` (sharper, less ghosting; `0.25` is faster) and
`switch-lsfg-performance: false` (quality shaders; `true` is faster).

---

## Configuration

Files in `sdmc:/switch/gravityrush/`:

| File | Purpose |
|---|---|
| `config/config.yml` | Emulator settings (resolution, buttons, frame generation, logging ...). Created on first launch. |
| `motion.txt` | *(optional)* Gyro / accelerometer axis mapping for a Pro Controller. Re-read every ~2 s while playing. |
| `vita3k.log` | Log (warnings and errors). Readable after the game closes. |
| `vita3k.live.log` | The last 500 log lines, updated every 5 s while the game runs. |
| `boot.log` | Start-up checkpoints. The last line shows how far start-up got. |

Useful `config.yml` keys: `resolution-multiplier` (default `2`), `switch-button-a/b/x/y`
(`circle`, `cross`, `triangle`, `square`), `performance-overlay`, `switch-lsfg-enabled`, `log-level`.

`motion.txt` format: each output axis takes a signed input axis (0, 1, 2). The built-in default is:
```
gyro = +0 +2 -1
accel = +0 +1 +2
```
If a motion direction is reversed, flip the sign of that axis. If yaw and roll are swapped, swap the
last two gyro entries.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Stuck on the **Gravity Rush logo** forever | The game files are damaged or incomplete, usually `Gravite.psarc`. Copy `ux0/app/PCSA00011` again from the PC where the game works, and check that `args.txt` contains `-region A`. |
| "**Gravity Rush (PCSA00011) is not installed**" | The game isn't at `sdmc:/switch/gravityrush/fs/ux0/app/PCSA00011/`. Check that the `fs` folder holds the *contents* of Vita3K's file system folder. |
| Crash or black screen right after launch | Check `boot.log` and `vita3k.log`. Make sure the firmware (`vs0`, `os0`) was copied. |
| **Frame generation: unavailable** | It's off in Settings, or `Lossless.dll` is missing or isn't from the `lsfg-vk` beta branch. `vita3k.log` says which. |
| Trophy pop-ups without text | Should not happen: the build falls back to the Switch's system font when the Vita font package isn't installed. |
| Game stays black after quitting | Press HOME and close the software. |

Including `vita3k.log`, `boot.log` and `vita3k.live.log` in bug reports helps a lot.

---

## Building from source

Requirements: Linux (or WSL), [devkitPro](https://devkitpro.org) with devkitA64 and the Switch
portlibs, the **ounce-devkit** installed into devkitPro (`$DEVKITPRO/libounce`,
`$DEVKITPRO/portlibs/switch2`), CMake ≥ 3.22, Ninja, Perl, curl, git.

```sh
git clone --recurse-submodules <this repository> gravityrush-switch2
cd gravityrush-switch2
./switch2-configure.sh             # applies submodule patches, builds OpenSSL once, configures CMake
ninja -C build/switch2 vita3k_nro  # -> build/switch2/GravityRush.nro
```

`ninja -j3` keeps memory use down on machines with ≤16 GB RAM. LTO is off in this build.

Switch 2 specifics live in `cmake/switch2.cmake`, `vita3k/switch2/`, the `VITA3K_SWITCH2` blocks in
`vita3k/switch/`, and the kaiHEN JIT changes in `patches/submodules/dynarmic-switch.patch`.

---

## Credits and license

- **[Vita3K](https://github.com/Vita3K/Vita3K)**: the Vita3K team. Licensed under the GNU GPL v2
  (see `COPYING.txt`).
- **[Vita3K-nx](https://github.com/NaGaa95/Vita3K-nx)**: the Switch 1 port this build is based on.
  The original README is in `README-Vita3K-nx.md`.
- **kaiHEN** and the **ounce-devkit** (libounce, OunceVK / Mesa NVK, mimalloc): ISC / MIT licensed.
  Their notices are in the release zip under `licenses/`.
- **[lsfg-vk](https://github.com/PancakeTAS/lsfg-vk)**: frame generation bridge. Lossless Scaling
  itself is not included.
- **OpenSSL** (Apache 2.0), **SDL**, **dynarmic** and the other libraries listed in `external/`.

This project is not affiliated with Sony Interactive Entertainment, Nintendo, or the authors of
Lossless Scaling. Gravity Rush is a trademark of Sony Interactive Entertainment. Use only games and
firmware you own.
