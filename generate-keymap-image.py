#!/bin/python3
from rich.console import Console
import subprocess

console = Console()
# use rich to show green text "appliation starting" in green text
console.print("Starting generation")

console.print("🛠️ Converting keymap into yaml file")
with open("keymap-drawer/eyelash_sofle.yaml", "w") as f:
    subprocess.run([
        "keymap",
        "parse",
        "-c", "10",
        "-z", "config/eyelash_sofle.keymap"
    ], stdout=f, check=True)

console.print("🛠️ Converting yaml into svg")
with open("keymap-drawer/eyelash_sofle.svg", "w") as f:
    subprocess.run(
        ["keymap", "draw", "keymap-drawer/eyelash_sofle.yaml"],
        stdout=f,
        check=True
    )
# keymap parse -c 10 -z config/eyelash_sofle.keymap > keymap-drawer/eyelash_sofle.yaml
#keymap draw keymap-drawer/eyelash_sofle.yaml > keymap-drawer/eyelash_sofle.svg

console.print("[green]Generation complete![/green]")
