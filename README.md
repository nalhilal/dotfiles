# My Dotfiles

Personal configuration files for my development environment, themed with [Synthwave 2077](https://github.com/faisalnjs/Synthwave-2077).

## Installation

```bash
git clone https://github.com/nalhilal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The installer is interactive, modular, and safe. It backs up existing configurations and lets you choose which packages to install.

**Options:**
```bash
./install.sh              # Interactive mode
./install.sh --all        # Install everything
./install.sh nvim zsh     # Install specific packages
./install.sh --help       # Show all options
```

## What's Included

**Shell Configurations:**
- [bash](bash/) - Modular bash config with dotfiles-as-extension pattern
- [zsh](zsh/) - Modular zsh config with ZDOTDIR
- [starship](starship/) - Cross-shell prompt with Synthwave 2077 theme

**Development Tools:**
- [nvim](nvim/) - Lua-based Neovim with LSP, Telescope, Treesitter
- [git](git/) - Git configuration with machine-specific local config
- [lazygit](lazygit/) - Terminal UI for git with AI commit messages
- [tmux](tmux/) - Terminal multiplexer with vim integration

**CLI Tools:**
- [zoxide](zoxide/) - Smart cd replacement
- **bat** - Cat replacement with syntax highlighting (configured in shell dotfiles)
- **eza** - Modern ls replacement (configured in shell dotfiles)
- **fzf** - Fuzzy finder (configured in shell dotfiles)

**Terminal:**
- [wezterm](wezterm/) - Cross-platform terminal with Synthwave 2077 theme

## Architecture

This repository uses GNU Stow for symlink management and follows a **dotfiles-as-extension pattern** where system shell RC files minimally source dotfiles configurations. See [CLAUDE.md](CLAUDE.md) for detailed architecture documentation.

## Theme

Cohesive **Synthwave 2077** aesthetic across all tools with vibrant pinks, purples, cyans, and neon greens.

## License

[MIT](LICENSE)
