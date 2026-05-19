# ZMK Debugging Skill

Helps debug ZMK firmware build failures in GitHub Actions and local builds, particularly for zmk-config repos with custom boards.

## Common Issues

### 1. CI Workflow / ZMK Version Mismatch

**Error:**
```
KeyError: 'qualifiers'
File ".../west_commands/boards.py", line 87, in do_run
```

**Cause:** The GitHub Actions workflow (`build-user-config.yml`) is pinned to `@main` (ZMK's latest), but `west.yml` pins ZMK to an older tag like `v0.3.0`. The `@main` workflow added a check step that runs `west boards --format "{qualifiers}"`, which older ZMK versions don't support.

**Fix:** Match the workflow branch to the ZMK version in `west.yml`:
- If `west.yml` uses `revision: v0.3.0`, change `@main` to `@v0.3-branch`
- If `west.yml` uses `revision: main`, `@main` is correct

Edit `.github/workflows/build.yml`:
```
- uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@main
+ uses: zmkfirmware/zmk/.github/workflows/build-user-config.yml@v0.3-branch
```

### 2. West Init/Update Failures

**Error:** Network timeout or "west update" fails fetching modules.

**Fix:** Check `west.yml` for unreachable remotes or invalid revisions. Run locally:
```bash
west init -l config
west update
```

### 3. Board Not Found

**Error:** `Board not found` for custom board.

**Fix:** Ensure custom board files live in `boards/arm/<board_name>/` with:
- `<board_name>.dts` (left/right variants)
- `<board_name>.yaml` (board metadata)
- `<board_name>_defconfig` (Kconfig defaults)
- `Kconfig.board`, `Kconfig.defconfig`

Verify the `west.yml` `self:` section:
```yaml
self:
  path: boards
```

### 4. Missing `build.yaml`

**Error:** "Empty build matrix" notice in CI.

**Fix:** Create `build.yaml` at repo root:
```yaml
# This file generates the build matrix
include:
  - board: eyelash_sofle_left
  - board: eyelash_sofle_right
```

### 5. Module Import Errors

**Error:** Custom shield/board module can't find `zmk,matrix-transform` or other bindings.

**Fix:** Ensure the module's `zephyr/module.yml` is present and references the correct ZEPHYR_BASE.

### 6. Common GitHub Actions CI Patterns

| Symptom | Likely Cause |
|---|---|
| Workflow not triggering | Check `on: push: paths-ignore:` in `build.yml` |
| Container issues | `zmk-build-arm:stable` might be outdated; try `:latest` |
| Artifact upload fails | GitHub Actions v4/v5 artifact action version mismatch |

## Local Debugging

To reproduce CI builds locally:
```bash
west build -s zmk/app -b eyelash_sofle_left -d build/left -- -DZMK_CONFIG="C:/path/to/config"
```

Enable verbose output:
```bash
west build -v ...
```
