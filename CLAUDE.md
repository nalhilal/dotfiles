# CLAUDE.md

Guidance for Claude Code when working with this dotfiles repository.

## Repository Overview

Personal dotfiles for macOS and Linux using GNU Stow for symlink management. Features a cohesive Synthwave 2077 aesthetic and follows a "dotfiles as extension" architecture for shell configurations.

## Architecture

### Stow Package Structure

Each package follows GNU Stow convention:
```
package_name/
  .config/
    package_name/
      <config files>
```

When stowed from `~/.dotfiles`, files symlink to `~/.config/package_name/`.

**CRITICAL**: Always use `stow` for symlinking - never `cp` or `ln` directly.

### Installation Script (Modular)

`install.sh` sources from `install/` directory:
- `utils.sh` - Logging, OS/shell detection
- `packages.sh` - Package management (check, backup, stow)
- `setup.sh` - Application-specific setup (zsh, git, tmux, etc.)
- `interactive.sh` - Interactive menu

Flow: init → check dependencies → interactive/CLI mode → `install_package()` → stow → setup functions

### Shell Extension Pattern

**CRITICAL**: Shell RC files are minimally modified to source dotfiles configs. All actual configuration lives in `~/.config/bash/` or `~/.config/zsh/`.

**Bash:**
- System `~/.bashrc` → sources `~/.config/bash/bashrc`
- System `~/.bash_profile` → sources `~/.config/bash/bash_profile`
- Dotfiles configs: `bashrc`, `bash_profile`, `settings.sh`, `aliases.sh`

**Zsh:**
- System `~/.zshenv` → sets `ZDOTDIR="$HOME/.config/zsh"`
- System `~/.zshrc` → placeholder (ignored)
- Dotfiles configs: `.zshrc`, `.zshenv`, `*.zsh` modular files

**Tool Setup Functions:**
- Only `setup_bash()` and `setup_zsh()` modify system RC files
- All other setup functions check prerequisites and detect conflicts
- Tool initializations are in stowed configs (declarative), not added dynamically

## Development Commands

### Testing
```bash
./test_install.sh  # Run before committing installation logic changes
```

Safe, non-destructive E2E tests in temp environment.

### Installation
```bash
./install.sh                # Interactive
./install.sh --all          # All packages
./install.sh nvim zsh       # Specific packages
stow -n nvim                # Dry run (manual)
```

### Git Workflow
```bash
# NEVER add Claude attribution or Co-Authored-By lines
# Use descriptive commit messages
# Test before committing

git config user.email "227337+nalhilal@users.noreply.github.com"
```

## Critical Implementation Details

### Adding New Packages

See individual tool READMEs for configuration details:
- [bash/](bash/README.md), [zsh/](zsh/README.md), [git/](git/README.md)
- [nvim/](nvim/README.md), [tmux/](tmux/README.md), [lazygit/](lazygit/README.md)
- [starship/](starship/README.md), [zoxide/](zoxide/README.md), [wezterm/](wezterm/README.md)

**Steps:**
1. Create package directory following stow convention
2. Update `AVAILABLE_PACKAGES` in `install/packages.sh`
3. Add cases to `is_already_stowed()` and `backup_existing()`
4. Add setup function in `install/setup.sh` if needed
5. Update `test_install.sh` with mock structure
6. Test: `./install.sh package_name` then `bash test_install.sh`
7. Add README to package folder

### Tmux: Git Submodules

Plugins are git submodules in `tmux/.config/tmux/plugins/` (XDG location).
- `setup_tmux()` runs `git submodule update --init --recursive`
- TPM itself is a submodule that loads other submodules
- Config MUST reference `~/.config/tmux/plugins/tpm/tpm`

### Lazygit: Cross-Platform

- **macOS**: `~/Library/Application Support/lazygit/` → symlinks to XDG
- **Linux**: `~/.config/lazygit/` (standard)
- `setup_lazygit()` creates macOS symlinks after stowing

### WezTerm: Runtime OS Detection

Config uses Lua runtime detection for fonts, cursor, padding. No install script handling needed.

## Common Gotchas

1. **Symlink Detection**: Use `readlink -f` (not `readlink`) - stow creates relative symlinks
2. **Error Messages**: Provide actionable suggestions
3. **RC File Modification**: Only in `setup_bash()` and `setup_zsh()` - check if already exists before appending
4. **Package Managers**: Handle systems without standard package managers

## Theme

Synthwave 2077 color palette:
- Pink: `#ff7edb`
- Purple: `#b893ce`
- Cyan: `#72f1b8`
- Neon green: `#fede5d`

Maintain this aesthetic when adding new configs.
