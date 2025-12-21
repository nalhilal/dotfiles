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
   - **git**: Creates `config.local` for machine-specific user details if it doesn't exist
   - **tmux**: Initializes git submodules for plugins (TPM and plugins), verifies plugin directory structure (see Tmux Git Submodules below)
   - **lazygit**: On macOS, creates symlinks from `~/Library/Application Support/lazygit/` to `~/.config/lazygit/` (see Lazygit Cross-Platform Handling below)
   - **zsh**: Creates `~/.zshenv` with ZDOTDIR, placeholder `~/.zshrc`, and `.zshrc.local`
   - **starship**: Checks/installs binary, detects shell, offers zsh integration, adds init to RC files
   - **zoxide**: Checks/installs binary, detects shell, adds init to RC files

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
# - NEVER add Claude attribution or Co-Authored-By lines
# - Use descriptive commit messages
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

Follow these comprehensive steps when adding a new package to the dotfiles repository:

**1. Prepare the Package Directory Structure**
```bash
# Create the package directory following stow convention
mkdir -p package_name/.config/package_name/

# Copy existing config to package directory
cp ~/.config/package_name/config_file package_name/.config/package_name/

# Create manual backup (install script will also backup during stow)
mkdir -p ~/.dotfiles_backup/manual_$(date +%Y%m%d_%H%M%S)
cp -r ~/.config/package_name ~/.dotfiles_backup/manual_$(date +%Y%m%d_%H%M%S)/
```

**2. Update install.sh**
- Add package to `AVAILABLE_PACKAGES` array (keep alphabetical order)
- Add case in `is_already_stowed()` function:
  ```bash
  package_name)
      target_dir="$HOME/.config/package_name"
      source_dir="$DOTFILES_DIR/package_name/.config/package_name"
      ;;
  ```
- Add case in `backup_existing()` function:
  ```bash
  package_name)
      if [ -e "$HOME/.config/package_name" ] && [ ! -L "$HOME/.config/package_name" ]; then
          mkdir -p "$backup_dir" || { print_error "..."; return 1; }
          mv "$HOME/.config/package_name" "$backup_dir/" || { print_error "..."; return 1; }
          print_warning "Backed up existing package_name config to: $backup_dir"
      fi
      ;;
  ```
- If package needs special setup (like binary installation or RC file modifications), add case in `install_package()` calling `setup_package_name()`

**3. Update test_install.sh**
- Add package to mock dotfiles structure in `setup_test_env()`:
  ```bash
  mkdir -p "$MOCK_DOTFILES/package_name/.config/package_name"
  echo "mock package config" > "$MOCK_DOTFILES/package_name/.config/package_name/config.yml"
  ```
- Add case to mock stow command:
  ```bash
  package_name)
      mkdir -p "$HOME/.config/package_name"
      ln -sf "$dotfiles_dir/package_name/.config/package_name/config.yml" "$HOME/.config/package_name/config.yml"
      ;;
  ```
- Update `AVAILABLE_PACKAGES` array in `test_error_handling()` test

**4. Test and Install**
```bash
# Remove original config directory (will be replaced by symlink)
rm -rf ~/.config/package_name

# Run install script for the new package
./install.sh package_name

# Verify symlinks are correct
ls -la ~/.config/package_name/
readlink -f ~/.config/package_name  # Should point to ~/.dotfiles/package_name/.config/package_name

# Run full test suite
bash test_install.sh
```

**5. Update README.md**
- Add package section in "What's Included" (keep alphabetical order)
- Remove from "Planned Additions" if listed there
- Add to manual installation examples:
  ```bash
  stow package_name
  ```

**6. Update CLAUDE.md**
- Add any package-specific gotchas or special handling notes
- Update examples in relevant sections if the package introduces new patterns

**7. Verify and Commit**
```bash
# Check git status to see all changes
git status

# Verify package works with the stowed config
# (test the actual application)

# Run test suite one final time
bash test_install.sh

# Commit changes (will use proper commit message format)
git add .
git commit -m "Add package_name to dotfiles

- Create package_name package directory structure
- Add to install.sh and test_install.sh
- Update README.md documentation
- Verify symlinks and test installation"

# Push to remote
git push
```

**Common Package Types:**
- **Simple config-only** (like nvim, wezterm): Just stow the config files, no special setup needed
- **Cross-platform config** (like lazygit): Needs OS-specific setup to handle different config locations
- **Binary + config** (like starship): Needs `setup_package_name()` function to check/install binary and modify RC files
- **Git submodules** (like tmux): Requires submodule initialization in setup function
- **Complex setup** (like zsh): Requires multiple file creation and special handling in setup function

### Tmux Git Submodules

**CRITICAL**: Tmux plugins are managed as git submodules, not installed via package manager or TPM's install mechanism.

**Architecture**:
- Plugins are in `tmux/.config/tmux/plugins/` (XDG location, NOT `~/.tmux/plugins/`)
- Each plugin is a git submodule defined in `.gitmodules`
- TPM itself is a submodule that loads other submodules
- Config file MUST reference `~/.config/tmux/plugins/tpm/tpm` not `~/.tmux/plugins/tpm/tpm`

**Implementation Details**:
- `setup_tmux()`: Checks if `tpm/tpm` executable exists, runs `git submodule update --init --recursive` if missing
- `is_already_stowed()`: No special handling needed - checks standard XDG location
- `backup_existing()`: No special handling needed - backs up `~/.config/tmux` if it exists
- `test_install.sh`: Creates mock plugin directories and mock `tpm` executable; mock git command simulates submodule init

**Why This Approach**:
- Git submodules ensure plugins are version-controlled and reproducible
- No need to run `prefix + I` manually after installation
- Single `git submodule update --init --recursive` initializes all plugins at once
- Plugins work immediately after stowing and submodule init
- Consistent with dotfiles philosophy: everything in version control

**Common Gotcha**: If tmux config references wrong path (`~/.tmux/plugins/` instead of `~/.config/tmux/plugins/`), TPM won't load and plugins won't work. Always use XDG paths.

### Lazygit Cross-Platform Handling

**CRITICAL**: Lazygit has different default config locations on macOS vs Linux:
- **macOS**: `~/Library/Application Support/lazygit/config.yml`
- **Linux**: `~/.config/lazygit/config.yml`

**Our Solution**: We use stow to manage configs in XDG location (`~/.config/lazygit/`) on all platforms, then:
1. On Linux: lazygit reads directly from `~/.config/lazygit/` (standard XDG location)
2. On macOS: `setup_lazygit()` creates symlinks from Library location to XDG location:
   - `~/Library/Application Support/lazygit/config.yml` -> `~/.config/lazygit/config.yml`
   - `~/Library/Application Support/lazygit/ai-commit.sh` -> `~/.config/lazygit/ai-commit.sh`

**Implementation Details**:
- `is_already_stowed()`: Checks appropriate location based on OS (Library on macOS, XDG on Linux)
- `backup_existing()`: Backs up both XDG and macOS Library locations if they exist
- `setup_lazygit()`: Creates macOS symlinks after stowing (only on macOS)
- `test_install.sh`: Mock stow creates XDG location; setup creates Library symlinks on macOS

**Why This Approach**:
- Single source of truth (stowed files in `~/.config/lazygit/`)
- Works across macOS and Linux without duplicating config
- Respects each OS's default config location
- Allows custom scripts (like `ai-commit.sh`) to work seamlessly

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
