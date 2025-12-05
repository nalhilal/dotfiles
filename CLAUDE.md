# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository for managing development environment configurations across macOS and Linux systems. The repository uses **GNU Stow** for symlink management and features a cohesive Synthwave 2077 aesthetic across all tools.

## Architecture

### Stow-Based Package Structure

The repository follows GNU Stow's directory structure where each package (nvim, starship, wezterm, zsh) contains its target directory structure:

```
package_name/
  .config/
    package_name/
      <config files>
```

When stowed from `~/.dotfiles`, files are symlinked to their target locations (e.g., `~/.config/nvim/`). **CRITICAL**: Always use `stow` for symlinking - never use `cp` or `ln` directly in install scripts.

### Installation Script Architecture

**install.sh** is the main installation orchestrator with these key responsibilities:

1. **Cross-Platform Support**: Detects OS (macOS/Linux) and package managers (brew/apt/pacman/dnf/yum)
2. **Package Installation Flow**:
   - Validates package directory exists
   - Checks if already stowed (using `readlink -f` for relative symlink resolution)
   - Backs up existing configurations to `~/.dotfiles_backup/TIMESTAMP/`
   - Runs `stow <package>` from `$DOTFILES_DIR`
   - Executes package-specific setup functions

3. **Special Package Handlers**:
   - **zsh**: Creates `~/.zshenv` with ZDOTDIR, placeholder `~/.zshrc`, and `.zshrc.local`
   - **starship**: Checks/installs binary, detects shell, offers zsh integration, adds init to RC files

### Key Design Patterns

**Error Handling**: Script uses `set -e` with explicit error checking. All functions return 0 (success) or 1 (failure) with descriptive error messages via `print_error()`.

**Symlink Verification**: `is_already_stowed()` uses `readlink -f` to resolve relative symlinks to absolute paths before comparing with source directory. This handles both relative (`../.dotfiles/...`) and absolute symlinks.

**Shell RC File Detection**: Respects ZDOTDIR for zsh, falls back to standard locations, creates files if missing.

## Development Commands

### Testing

```bash
# Run full test suite (33 tests across 13 scenarios)
bash test_install.sh

# Tests are non-destructive - use temporary directory with mock environment
# All tests must pass before committing install.sh changes
```

Test suite validates:
- OS/package manager detection
- Symlink creation and verification (including relative vs absolute paths)
- Backup operations with error handling
- Package-specific setups (zsh, starship)
- `.zshrc.local` preservation across reinstalls

### Installation Testing

```bash
# Interactive mode (default)
./install.sh

# Non-interactive modes
./install.sh --all              # Install all packages
./install.sh nvim zsh           # Install specific packages
./install.sh --help             # Show usage

# Manual stow (for development/testing)
stow -n nvim                    # Dry run
stow nvim                       # Execute
stow -D nvim                    # Unstow (remove symlinks)
```

### Git Workflow

```bash
# Commit conventions
# - Use descriptive commit messages with emoji: 🤖 Generated with [Claude Code]
# - Include Co-Authored-By: Claude <227337+nalhilal@users.noreply.github.com>
# - Test before committing: bash test_install.sh

# User's git email is set to GitHub noreply address
git config user.email "227337+nalhilal@users.noreply.github.com"
```

## Critical Implementation Details

### Binary Installation Pattern (Starship Example)

When adding new packages that require binary installation:

1. Check if binary exists: `check_binary_installed "binary_name"`
2. Prompt user for installation with OS-appropriate command
3. Use `install_binary()` which calls `get_install_command(package)`
4. Detect shell and add initialization to RC files
5. Offer related package installation (e.g., zsh config for starship users)
6. Use `stow` for all configuration files

### Adding New Packages

1. Create package directory: `package_name/.config/package_name/`
2. Add to `AVAILABLE_PACKAGES` array in install.sh
3. Add case in `is_already_stowed()` and `backup_existing()`
4. If needs special setup, add case in `install_package()` calling `setup_package_name()`
5. Create tests in test_install.sh
6. Update README.md

### Zsh Special Handling

Zsh uses ZDOTDIR (`~/.config/zsh/`) to keep home directory clean:
- `~/.zshenv` (created by installer) exports ZDOTDIR
- `~/.zshrc` (placeholder) exists for installers that try to modify it
- `~/.config/zsh/.zshrc` (stowed) is the actual config
- `~/.config/zsh/.zshrc.local` (not tracked) for machine-specific settings

### WezTerm Cross-Platform Config

WezTerm config uses runtime OS detection in Lua:
- Detects macOS vs Linux vs Arch
- Sets fonts, cursor styles, padding per platform
- All detection happens in wezterm.lua, not install script

## Common Gotchas

1. **Symlink Detection**: Always use `readlink -f` not `readlink` - stow creates relative symlinks
2. **Echo Colors**: Use `echo -e` when outputting color variables (`${CYAN}`, etc.)
3. **RC File Modification**: Always check if initialization already exists before appending
4. **Package Manager Detection**: Must handle systems without standard package managers
5. **Error Messages**: Provide actionable suggestions (e.g., manual install commands)

## Theme Consistency

All configurations share Synthwave 2077 color palette:
- Pink: `#ff7edb`
- Purple: `#b893ce`
- Cyan: `#72f1b8`
- Neon green: `#fede5d`

When adding new configs, maintain this aesthetic.
