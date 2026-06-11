# Starship Prompt Configuration

Cross-shell prompt with custom Synthwave 2077 theme and automatic light/dark mode selection.

## Features

- OS-aware icon display (Arch, macOS, Ubuntu, Debian, Fedora, etc.)
- Color-coded directory display with icon substitutions
- Git branch and status indicators
- Language version display (Node.js, Rust, Go, PHP)
- Time display with matching color palette
- Automatic light/dark config selection based on system appearance

## Light/Dark Mode

The shell initializer selects the appropriate Starship config at startup:

| Config | Palette | When used |
|--------|---------|-----------|
| `starship.toml` | `synthwave_2077` | Dark mode (default) |
| `starship.light.toml` | `synthwave_2077_light` | Light mode |

Detection order (terminal-agnostic):

1. `STARSHIP_CONFIG` — if already set, left unchanged
2. `STARSHIP_APPEARANCE=light|dark` — manual override
3. **macOS** — `defaults read -g AppleInterfaceStyle` (matches scheduled system appearance)
4. **`COLORFGBG`** — background index `15` or `7–9` indicates a light terminal
5. **Fallback** — dark

Override examples:

```bash
STARSHIP_APPEARANCE=light exec $SHELL
STARSHIP_APPEARANCE=dark exec $SHELL
```

Appearance changes mid-session require a new shell (`exec $SHELL`) to take effect.

## Shell Integration

Appearance detection and `starship init` live in the shell packages (sourced on startup):

- `zsh/.config/zsh/starship.zsh` — zsh (sourced from `.zshrc`)
- `bash/.config/bash/starship.sh` — bash (sourced from `bashrc`)

## Maintaining Configs

Module settings live in `starship.toml`. After editing, regenerate the light config:

```bash
./starship/sync_light_config.sh
```

This copies `starship.toml` to `starship.light.toml` and switches the active palette to `synthwave_2077_light`.

## Installation

```bash
./install.sh starship
```

The installer checks for the starship binary and offers to install it if missing. Detects conflicts with existing manual initializations in shell RC files.

Stowed files:

```
~/.config/starship.toml
~/.config/starship.light.toml
```

Install shell packages for init logic: `./install.sh zsh bash`
