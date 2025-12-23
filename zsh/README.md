# Zsh Configuration

Modular Zsh configuration using the **dotfiles as extension pattern** with ZDOTDIR.

## Structure

**System Files** (automatically created by installer):
- `~/.zshenv` - Sets `ZDOTDIR="$HOME/.config/zsh"` to redirect zsh to dotfiles
- `~/.zshrc` - Placeholder file with warnings (ignored when ZDOTDIR is set)

**Dotfiles Configuration** (located in `~/.config/zsh/`):
- `.zshrc` - Main configuration, sources all modular files and sets bat as MANPAGER
- `.zshenv` - Environment variables
- `starship.zsh` - Starship prompt initialization
- `zoxide.zsh` - Zoxide (smart cd) setup
- `fzf.zsh` - Fuzzy finder configuration
- `git.zsh` - Git aliases and functions
- `nvim.zsh` - Neovim integration
- `extras.zsh` - Additional configurations (eza aliases, ngrok completion)

**Local Overrides**:
- `~/.config/zsh/.zshrc.local` - Machine-specific config (auto-generated, not tracked)

## Features

- Extensive history management with deduplication
- Synthwave 2077 syntax highlighting colors
- Integration with zsh-autosuggestions and zsh-syntax-highlighting
- Portable configuration separated from machine-specific settings

## Installation

```bash
./install.sh zsh
```

The installer automatically creates `~/.zshenv` and sets up the ZDOTDIR structure.
