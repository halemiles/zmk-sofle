# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

ZMK firmware configuration for the **eyelash_sofle** — a split 65-key keyboard based on the nRF52840 (nice!nano v2), with RGB underglow (WS2812), per-key backlight, a hat switch (not a rotary encoder), and a nice!view display. Firmware is built via GitHub Actions using the ZMK build pipeline.

There is no local build toolchain — all compilation happens in CI. To trigger a build, push to any branch or use `workflow_dispatch` on `.github/workflows/build-local.yml`.

## Repo structure

```
config/
  eyelash_sofle.conf     # Kconfig options (power, RGB, BLE, debounce, etc.)
  eyelash_sofle.keymap   # Key bindings, layers, macros, layer_listeners
  west.yml               # ZMK + module dependencies (source of truth for firmware version)
boards/arm/eyelash_sofle/
  *.dts / *.dtsi         # Hardware definitions (GPIO pins, LED strip, matrix)
  *_defconfig            # Per-side Kconfig defaults
build.yaml               # Which board/shield combos CI builds
```

## Key dependencies (west.yml)

- **ZMK**: `zmkfirmware/zmk @ v0.3.0` (official, not a fork)
- **Board support**: `a741725193/zmk-sofle @ main` (eyelash_sofle board files)
- **Per-layer RGB**: `ssbb/zmk-listeners @ v1` — provides `zmk,layer-listeners` node type

Do not switch ZMK to a fork (e.g. darknao's `rgb-layer` branch) without understanding that it replaces the entire ZMK dependency.

## How the per-layer RGB works

`config/eyelash_sofle.keymap` defines:

1. **Macros** (`rgb_layer1`–`rgb_layer4`) — each fires `RGB_ON` + `RGB_COLOR_HSB(...)` to set a colour.
2. **`layer_listeners`** node — wires each macro to layer entry, and `RGB_OFF` to layer exit.

Layer 0 (base) has no listener — underglow stays off. Layers 1–4 each show a distinct colour. The standard `rgb_ug` behaviors handle everything; no experimental config flags are needed.

## Important conf settings

| Setting | Value | Why |
|---|---|---|
| `ZMK_IDLE_TIMEOUT` | 60000 ms | Triggers RGB/backlight auto-off after 1 min idle |
| `ZMK_IDLE_SLEEP_TIMEOUT` | 900000 ms | Deep sleep (BLE off) after 15 min |
| `RGB_UNDERGLOW_ON_START` | n | Underglow off at boot; layer listeners bring it up |
| `BACKLIGHT_AUTO_OFF_IDLE` | y | Per-key backlight turns off with underglow |
| `BT_CTLR_TX_PWR_PLUS_8` | y | Max BLE TX power for range |

## Keymap layers

| # | Name | Purpose |
|---|---|---|
| 0 | LAYER0 | Base alphanumeric |
| 1 | Functions | F-keys, caret navigation, media |
| 2 | Special characters | Symbols, brackets |
| 3 | Controls | BT profiles, RGB manual controls, output switching |
| 4 | *(unnamed)* | Alternate base (toggled with `tog 4`) |

Layers 1 and 2 are accessed via `mo` on left/right thumb keys. Layer 3 is `mo` on the rightmost right-thumb key.

## Regenerating the keymap SVG

```bash
pip3 install keymap-drawer
keymap parse -c 10 -z config/eyelash_sofle.keymap > keymap-drawer/eyelash_sofle.yaml
keymap draw keymap-drawer/eyelash_sofle.yaml > keymap-drawer/eyelash_sofle.svg
```

## CI workflows

- **`build.yml`**: Triggers on push (ignores `keymap-drawer/`). Uses official ZMK build pipeline at `v0.3.0`. Suitable for branches on official ZMK.
- **`build-local.yml`**: Runs `west init` + `west update` then calls the upstream build action. Use this when `west.yml` references non-standard modules (e.g. `zmk-listeners`).
- **`draw.yml`**: Regenerates the keymap SVG.

`build.yaml` controls which board/shield combos are built (currently left + right with nice!view, plus a ZMK Studio left variant).
