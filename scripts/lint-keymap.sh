#!/usr/bin/env bash
#
# Lightweight sanity check for ZMK keymap/overlay files.
#
# This is NOT a full devicetree validator (the real ZMK build does that). It
# only greps for known Nickcoutsos keymap-editor footguns that break the build
# *before* compilation with cryptic errors. The goal is a fast, clear message.
#
# Currently catches:
#   - Empty `bindings = <>;` (e.g. an empty "new_macro" placeholder). Devicetree
#     treats this as an unset property and ZMK's gen_defines.py aborts.
#
# Usage:  scripts/lint-keymap.sh
# Exit:   0 = clean, 1 = problem found
#
set -euo pipefail

# Prefer git-tracked files; fall back to scanning config/ if not in a repo.
files="$(git ls-files '*.keymap' '*.overlay' '*.dtsi' 2>/dev/null || true)"
if [ -z "$files" ]; then
    files="$(find config -type f \( -name '*.keymap' -o -name '*.overlay' \) 2>/dev/null || true)"
fi

if [ -z "$files" ]; then
    echo "keymap lint: no keymap/overlay files found"
    exit 0
fi

status=0
for f in $files; do
    # Empty bindings array -> devicetree treats as unset -> build fails.
    if grep -nE 'bindings[[:space:]]*=[[:space:]]*<[[:space:]]*>[[:space:]]*;' "$f" >/dev/null 2>&1; then
        echo "ERROR: $f contains an empty 'bindings = <>;'"
        echo "       (usually an empty macro/behaviour left behind by the keymap editor)."
        grep -nE 'bindings[[:space:]]*=[[:space:]]*<[[:space:]]*>[[:space:]]*;' "$f" | sed 's/^/         /'
        status=1
    fi
done

if [ "$status" -eq 0 ]; then
    echo "keymap lint: OK"
fi
exit "$status"
