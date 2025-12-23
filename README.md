# My Dotfiles

Personal configuration files for my development environment, themed with [Synthwave 2077](https://github.com/faisalnjs/Synthwave-2077).

## Theme

This setup features a cohesive **Synthwave 2077** aesthetic across all tools, inspired by the [Synthwave 2077 VSCode theme](https://github.com/faisalnjs/Synthwave-2077). The color palette includes vibrant pinks, purples, cyans, and neon greens for a retro-futuristic cyberpunk look.

## Installation

Clone this repository to your home directory:

```bash
git clone https://github.com/nalhilal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### Quick Install (Recommended)

Run the interactive install script:

```bash
./install.sh
```

The script is **modular and safe**. It runs in a way that protects your existing data by backing up any conflicting configurations before installing.

It will:
- Detect your current shell
- Check for dependencies (GNU Stow)
- Backup existing configurations to `~/.dotfiles_backup/`
- Let you choose which packages to install
- Handle zsh setup automatically (creates `~/.zshenv`, `.zshrc`, etc.)

**Command-line options:**
```bash
./install.sh                    # Interactive mode
./install.sh --all              # Install everything
./install.sh nvim zsh           # Install specific packages
./install.sh --help             # Show all options
```

### Manual Installation

You can also use [GNU Stow](https://www.gnu.org/software/stow/) directly:

```bash
# Install all configs (note: bash, bat, eza, fzf have special setup, use ./install.sh for those)
stow git lazygit nvim starship tmux wezterm zoxide zsh

# Or install individually
stow bash    # Then run ./install.sh bash to set up RC file sourcing
stow git
stow lazygit
stow nvim
stow starship
stow tmux
stow wezterm
stow zoxide
stow zsh
```

**Note for bash**: If installing manually with stow, you need to set up RC file sourcing:
```bash
# Add to ~/.bashrc
echo 'if [ -f "$HOME/.config/bash/bashrc" ]; then source "$HOME/.config/bash/bashrc"; fi' >> ~/.bashrc

# Add to ~/.bash_profile
echo 'if [ -f "$HOME/.config/bash/bash_profile" ]; then source "$HOME/.config/bash/bash_profile"; fi' >> ~/.bash_profile
```

**Note for zsh**: If installing manually, you need to create `~/.zshenv`:
```bash
echo 'export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv
```

## What's Included

### Bash

Modular Bash configuration using the **dotfiles as extension pattern**:

**System Files** (automatically configured by installer):
- `~/.bashrc` - Minimally modified to source `~/.config/bash/bashrc`
- `~/.bash_profile` - Minimally modified to source `~/.config/bash/bash_profile`

**Dotfiles Configuration** (located in `~/.config/bash/`):
- `bashrc` - Main configuration, sources modular files and initializes tools
- `bash_profile` - Login shell configuration
- `settings.sh` - History settings, shell options, environment variables
- `aliases.sh` - All aliases (eza, git, nvim, navigation shortcuts)

**Local Overrides**:
- `~/.bashrc.local` - Machine-specific configuration (not version controlled)

To install: `./install.sh bash`. The installer will automatically set up your system `.bashrc` and `.bash_profile` to source the dotfiles configurations.

### Bat

A modern replacement for `cat` with syntax highlighting and Git integration:
- Syntax highlighting for many programming languages
- Git integration shows file modifications
- Line numbers and paging support
- Used as the MANPAGER in zsh configuration

The installer will offer to install the `bat` binary if not already present. Configuration is handled automatically through shell dotfiles (used for MANPAGER in zsh).

To install: `./install.sh bat`

### Eza

A modern replacement for `ls` with icons, colors, and Git awareness:
- File type icons and color-coded output
- Git status integration in file listings
- Tree view support with `lt` alias
- Configurable through `aliases.sh` in shell dotfiles

The installer checks for the `eza` binary and shell dotfiles (bash or zsh). Aliases are automatically configured in `~/.config/bash/aliases.sh` or `~/.config/zsh/extras.zsh`.

To install: `./install.sh eza`

**Note**: Install the `bash` or `zsh` package first for proper alias configuration.

### FZF

Fuzzy finder for command-line with shell integration:
- Fuzzy search for files, command history, and processes
- Keyboard-driven interface
- Integration with shell reverse search (Ctrl+R)

The installer will offer to install the `fzf` binary if not present. Configuration is handled through shell dotfiles (sourced in bash/zsh configs).

To install: `./install.sh fzf`

**Note**: Install the `bash` or `zsh` package first for proper integration.

### Git

Git configuration with a machine-specific local config support:
- Common aliases and settings
- `config.local` for user-specific settings (name, email, credentials) which is not version controlled

To install: `stow git`

### Neovim

A Lua-based Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Features include:
- LSP support for multiple languages
- Autocompletion with nvim-cmp
- Fuzzy finding with Telescope
- Treesitter syntax highlighting
- Git integration with gitsigns and fugitive
- Custom Synthwave 2077 color scheme in lualine
- Transparent background support
- Seamless tmux integration with vim-tmux-navigator

To install: `stow nvim` and launch Neovim. Plugins will install automatically.

### Lazygit

Terminal UI for git with custom command integration:
- AI-powered commit message generation using Claude Code
- Custom keybinding (C) for generating conventional commit messages
- Automatic commit message formatting with subject line and bullet points
- No AI attribution or extra commentary in commits

To install: `stow lazygit`

### Starship

Cross-shell prompt with a custom Synthwave 2077 theme featuring:
- OS-aware icon display (Arch, macOS, Ubuntu, Debian, Fedora, etc.)
- Color-coded directory display with icon substitutions
- Git branch and status indicators
- Language version display (Node.js, Rust, Go, PHP)
- Time display with matching color palette

To install: `stow starship`

### Tmux

Terminal multiplexer configuration with Synthwave 2077 theming:
- Vim-style keybindings for pane navigation (h/j/k/l)
- Seamless integration with Neovim via vim-tmux-navigator
- TPM (Tmux Plugin Manager) with useful plugins
- Session persistence with tmux-resurrect and tmux-continuum
- CPU/Memory monitoring display
- Custom status bar styling

**Plugins** (managed as git submodules):
- `tpm` - Tmux Plugin Manager
- `vim-tmux-navigator` - Seamless navigation between tmux panes and vim splits
- `tmux-resurrect` - Save and restore tmux sessions
- `tmux-continuum` - Automatic session saving
- `tmux-cpu-mem-monitor` - System resource monitoring

**Installation**:
```bash
./install.sh tmux  # Recommended - automatically initializes submodules
# OR
stow tmux && git submodule update --init --recursive  # Manual method
```

The install script automatically:
1. Initializes git submodules for tmux plugins
2. Stows the configuration to `~/.config/tmux/`
3. Plugins load automatically when tmux starts

**Important**: The config uses `~/.config/tmux/plugins/` (XDG directory) not `~/.tmux/plugins/`

### WezTerm

Cross-platform terminal emulator configuration featuring:
- Synthwave 2077 custom color scheme
- Transparent background with blur effects
- Minimal window decorations
- OS-specific optimizations:
  - **macOS**: D2CodingLigature Nerd Font, blinking bar cursor, minimal padding
  - **Linux**: JetBrains Mono Nerd Font, steady block cursor, comfortable padding
  - Platform-specific key bindings and mouse support
- Automatic OS detection and configuration adjustment

To install: `stow wezterm`

### Zoxide

A smarter cd command that remembers your most used directories:
- Fast navigation to frequently used paths
- Integration with your shell (zsh, bash, fish)
- Interactive selection

To install: `stow zoxide`

### Zsh

Modular Zsh configuration using the **dotfiles as extension pattern** with ZDOTDIR:

**System Files** (automatically created by installer):
- `~/.zshenv` - Sets `ZDOTDIR="$HOME/.config/zsh"` to redirect zsh to dotfiles
- `~/.zshrc` - Placeholder file with warnings (ignored when ZDOTDIR is set)

**Dotfiles Configuration** (located in `~/.config/zsh/`):
- `.zshrc` - Main configuration, sources all modular files
- `.zshenv` - Environment variables
- `starship.zsh` - Starship prompt initialization
- `zoxide.zsh` - Zoxide (smart cd) setup
- `fzf.zsh` - Fuzzy finder configuration
- `git.zsh` - Git aliases and functions
- `nvim.zsh` - Neovim integration
- `extras.zsh` - Additional configurations (eza aliases, bat manpager)

**Local Overrides**:
- `~/.config/zsh/.zshrc.local` - Machine-specific config (auto-generated, not tracked)

**Features**:
- Extensive history management with deduplication
- Synthwave 2077 syntax highlighting colors
- Integration with zsh-autosuggestions and zsh-syntax-highlighting
- Portable configuration separated from machine-specific settings

To install: `./install.sh zsh`. The installer will automatically create `~/.zshenv` and set up the ZDOTDIR structure.

## Planned Additions

Configurations I plan to add:

- **fd** - Fast and user-friendly alternative to find
- **ripgrep** - Fast search tool
- **lazydocker** - Terminal UI for docker
- **yazi** - Terminal file manager
- **claude-code** - AI-powered coding assistant
- **cursor-agent** - AI code editor
- **google-cli** - Google Cloud CLI
- **pipx** - Install and run Python applications in isolated environments
- **mise** - Unified package manager for many languages
- **tldr** - Simplified man pages
- **navi** - Interactive cheatsheet tool
- **pass** - Password manager
- **doppler** - Secrets management
- **jq** - JSON processor
- **posting** - Terminal-based API client


## Contributing

These are my personal dotfiles, but feel free to fork and adapt them for your own use.

## License

[MIT](LICENSE)
