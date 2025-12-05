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

Individual configurations can be symlinked as needed. I recommend using [GNU Stow](https://www.gnu.org/software/stow/) for managing symlinks:

```bash
# Install all configs
stow nvim starship wezterm

# Or install individually
stow nvim
stow starship
stow wezterm
```

Or manually symlink specific configurations:

```bash
ln -s ~/.dotfiles/nvim ~/.config/nvim
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

## Planned Additions

Configurations I plan to add:

- **fzf** - Command-line fuzzy finder
- **bat** - Cat clone with syntax highlighting
- **ripgrep** - Fast search tool
- **lazygit** - Terminal UI for git
- **lazydocker** - Terminal UI for docker
- **git** - Version control configuration
- **yazi** - Terminal file manager
- **claude-code** - AI-powered coding assistant
- **cursor-agent** - AI code editor
- **google-cli** - Google Cloud CLI
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
