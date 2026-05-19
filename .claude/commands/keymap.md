# Keymap Editor

You are helping the user view, understand, and edit the ZMK keymap for their eyelash_sofle split keyboard.

## Keyboard layout

The eyelash_sofle has 5 rows. Each row has 6 keys on the left half, 1 hat switch in the centre, and 6 keys on the right half (bottom row has 5 right-side keys). Position numbers run left-to-right, top-to-bottom:

```
POS  LEFT HALF                        HAT    RIGHT HALF
Row0:  0   1   2   3   4   5         [H0]    6   7   8   9  10  11
Row1: 12  13  14  15  16  17         [H1]   18  19  20  21  22  23
Row2: 24  25  26  27  28  29         [H2]   30  31  32  33  34  35
Row3: 36  37  38  39  40  41         [H3]   42  43  44  45  46  47
Row4: 48  49  50  51  52  53         [H4]   54  55  56  57  58
```

Hat positions [H0–H4] correspond to the 7th binding in each row of the keymap file.

## How to read the keymap file

The keymap is at `config/eyelash_sofle.keymap`. Each layer lists bindings in row order, left-to-right. The 7th binding on every row is the hat switch. `&trans` means the key falls through to the layer below; treat it as an available slot on that layer.

## Step 1 — Always start by reading the keymap

Before responding to any request, read `config/eyelash_sofle.keymap` in full.

## Step 2 — Render the requested layer(s) as a grid

Display each layer like this (abbreviate long binding names to fit — strip `&kp `, `&rgb_ug `, etc.):

```
LAYER 0 — LAYER0
┌──────┬──────┬──────┬──────┬──────┬──────┐ [SCRL_UP ] ┌──────┬──────┬──────┬──────┬──────┬──────┐
│ ESC  │  1   │  2   │  3   │  4   │  5   │             │  6   │  7   │  8   │  9   │  0   │ BSPC │
├──────┼──────┼──────┼──────┼──────┼──────┤ [SCRL_DN ] ├──────┼──────┼──────┼──────┼──────┼──────┤
│ TAB  │  Q   │  W   │  E   │  R   │  T   │             │  Y   │  U   │  I   │  O   │  P   │ DEL  │
├──────┼──────┼──────┼──────┼──────┼──────┤ [SCRL_L  ] ├──────┼──────┼──────┼──────┼──────┼──────┤
│ SHFT │  A   │  S   │  D   │  F   │  G   │             │  H   │  J   │  K   │  L   │  ;   │  '   │
├──────┼──────┼──────┼──────┼──────┼──────┤ [SCRL_R  ] ├──────┼──────┼──────┼──────┼──────┼──────┤
│ CTRL │  Z   │  X   │  C   │  V   │  B   │             │  N   │  M   │  ,   │  .   │  /   │  \   │
└──────┴──────┼──────┼──────┼──────┼──────┤ [RCLK    ] ├──────┼──────┼──────┼──────┼──────┴──────┘
              │ ---- │ SL4  │ MO2  │ MO1  │             │  SPC │ ENT  │ RGUI │ MO3  │
              └──────┴──────┴──────┴──────┘             └──────┴──────┴──────┴──────┘
```

Use `----` for `&trans` keys. Use the actual short label for everything else.

## Step 3 — Conflict checking

When the user wants to add or change a binding:

1. Show the target key's current binding on the requested layer.
2. If it is already bound (not `&trans`), warn: **"Position X on layer N is already bound to Y — changing it will remove that."**
3. If it is `&trans`, show what it falls through to (check parent layers below it).
4. If the user is adding to a higher layer (e.g. layer 2), remind them that the same position on layer 0 will still fire when this layer is not active.
5. Show the surrounding keys in a small 3×3 excerpt so the user can see context.

## Step 4 — Suggest available slots

If the user asks "where can I put X", show all `&trans` positions on the target layer as a grid with position numbers marked. Cluster suggestions by region (top-right, bottom-left thumb cluster, etc.) so the user can reason about ergonomics.

## Step 5 — Optionally regenerate the SVG

If the user wants a visual after editing, run:

```bash
keymap parse -c 10 -z config/eyelash_sofle.keymap > keymap-drawer/eyelash_sofle.yaml && keymap draw keymap-drawer/eyelash_sofle.yaml > keymap-drawer/eyelash_sofle.svg
```

Tell the user the SVG is at `keymap-drawer/eyelash_sofle.svg` and they can open it to see the full rendered layout.

## Layer reference

| # | Name | Access |
|---|---|---|
| 0 | LAYER0 | Base — always active |
| 1 | Functions | Hold MO1 (left thumb inner) |
| 2 | Special characters | Hold MO2 (left thumb outer) |
| 3 | Controls | Hold MO3 (right thumb inner) |
| 4 | Games | SL4 toggle (left thumb second) |

## Arguments

`$ARGUMENTS` may contain:
- A layer number or name: `show layer 2`, `layer 3`
- A change request: `add COPY to layer 1`, `move PRINTSCREEN`
- `all` — show every layer
- `available` — show all `&trans` slots across all layers
- No argument — show layer 0 and ask what the user wants to do

Always confirm edits with the user before writing to the file. After writing, offer to regenerate the SVG.
