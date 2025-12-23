# Bat Configuration

Modern replacement for `cat` with syntax highlighting and Git integration.

## What This Package Provides

This package installs bat aliases for your shell, following the dotfiles extension philosophy. Actual bat configuration lives in the shell dotfiles (bash/zsh), where bat is configured as the MANPAGER.

### Aliases

- `cat` → `bat --paging=never` - Shows full file with syntax highlighting (no paging)
- `less` → `bat` - Paged view with syntax highlighting
- `catp` → `bat --style=plain` - Plain style (minimal decorations)
- `bathelp` → `bat --help` - Show bat help

### Shell Integration

The package provides shell-specific alias files that are conditionally sourced by your shell configuration:
- **Bash**: `bat/.config/bash/bat.sh` → sourced by `~/.config/bash/bashrc`
- **Zsh**: `bat/.config/zsh/bat.zsh` → sourced by `~/.config/zsh/.zshrc`

## Installation

```bash
# Install bat package (stows aliases and optionally installs binary)
./install.sh bat

# Reload your shell
exec $SHELL
```

The setup script will:
1. Check if the `bat` binary is installed (offers to install if missing)
2. Stow the shell-specific alias files to `~/.config/{bash,zsh}/`
3. Detect and offer to comment out conflicting `cat` aliases in your local RC files
4. Verify that bash/zsh dotfiles are installed (prerequisite)

## Dependencies

- `bat` binary (installed automatically via package manager if you confirm)
- bash or zsh dotfiles package (for shell integration)

## Features

- **Syntax Highlighting**: Automatic language detection and syntax highlighting
- **Git Integration**: Shows file modifications in the sidebar
- **Line Numbers**: Enabled by default (disabled with `--plain`)
- **Pager**: Automatic paging for large files (when using `less` alias)
- **MANPAGER**: Configured in shell RC files to use bat for man pages

## Manual Installation

If you prefer to install bat manually:

```bash
# macOS
brew install bat

# Linux (Debian/Ubuntu)
sudo apt-get install bat

# Linux (Fedora)
sudo dnf install bat
```

Then stow the aliases:
```bash
cd ~/.dotfiles && stow bat
```

## Customization

To override or add aliases, edit your local shell config:
- **Bash**: `~/.bashrc` or `~/.config/bash/bashrc.local`
- **Zsh**: `~/.config/zsh/.zshrc.local`

## Notes

- Bat aliases are only activated if the `bat` binary is detected
- The `cat` alias preserves bat's syntax highlighting while removing pagination
- For traditional cat behavior without colors, use `\cat` or `/bin/cat`
- Configuration follows the shell extension philosophy: alias files are symlinked, not copied
