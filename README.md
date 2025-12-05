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

The script will:
- Detect your current shell
- Check for dependencies (GNU Stow)
- Backup existing configurations
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
# Install all configs
stow nvim starship wezterm zsh

# Or install individually
stow nvim
stow starship
stow wezterm
stow zsh
```

**Note for zsh**: If installing manually, you need to create `~/.zshenv`:
```bash
echo 'export ZDOTDIR="$HOME/.config/zsh"' > ~/.zshenv
```

## What's Included

### Neovim

A Lua-based Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Features include:
- LSP support for multiple languages
- Autocompletion with nvim-cmp
- Fuzzy finding with Telescope
- Treesitter syntax highlighting
- Git integration with gitsigns and fugitive
- Custom Synthwave 2077 color scheme
- Transparent background support

To install: `stow nvim` and launch Neovim. Plugins will install automatically.

### Starship

Cross-shell prompt with a custom Synthwave 2077 theme featuring:
- Color-coded directory display with icon substitutions
- Git branch and status indicators
- Language version display (Node.js, Rust, Go, PHP)
- Time display with matching color palette

To install: `stow starship`

### WezTerm

Terminal emulator configuration featuring:
- Synthwave 2077 custom color scheme
- CaskaydiaCove Nerd Font
- Transparent background with blur effects
- Minimal window decorations
- Optimized padding and font size

To install: `stow wezterm`

### Zsh

Modular zsh configuration using ZDOTDIR for clean home directory:
- Portable configuration separated from machine-specific settings
- History management with extensive options
- Integration with zsh-autosuggestions and zsh-syntax-highlighting
- Modular files for different tools (fzf, git, nvim, zoxide)
- Machine-specific config in `.zshrc.local` (not version controlled)

**Files**:
- `.zshrc` - Main configuration (portable)
- `.zshenv` - Environment variables (portable)
- `.zshrc.local` - Machine-specific config (auto-generated, not tracked)
- `starship.zsh` - Starship prompt initialization
- `fzf.zsh` - FZF configuration
- `git.zsh` - Git aliases
- `nvim.zsh` - Neovim integration
- `zoxide.zsh` - Zoxide setup
- `extras.zsh` - Additional configurations

To install: `stow zsh`, then create `~/.zshenv` as shown in the installation section.

## Planned Additions

Configurations I plan to add:

- **fzf** - Command-line fuzzy finder
- **bat** - Cat clone with syntax highlighting
- **eza** - Modern replacement for ls with icons and colors
- **fd** - Fast and user-friendly alternative to find
- **ripgrep** - Fast search tool
- **tmux** - Terminal multiplexer
- **lazygit** - Terminal UI for git
- **lazydocker** - Terminal UI for docker
- **git** - Version control configuration
- **yazi** - Terminal file manager
- **claude-code** - AI-powered coding assistant
- **cursor-agent** - AI code editor
- **google-cli** - Google Cloud CLI
- **pipx** - Install and run Python applications in isolated environments
- **tldr** - Simplified man pages
- **navi** - Interactive cheatsheet tool
- **zoxide** - Smarter cd command
- **pass** - Password manager
- **doppler** - Secrets management
- **jq** - JSON processor
- **posting** - Terminal-based API client


## Contributing

These are my personal dotfiles, but feel free to fork and adapt them for your own use.

## License

[MIT](LICENSE)
