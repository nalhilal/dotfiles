# My Dotfiles

Personal configuration files for my development environment. This repository is a work in progress as I continue to refine and expand my setup.

## Installation

Clone this repository to your home directory:

```bash
git clone https://github.com/nalhilal/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

Individual configurations can be symlinked as needed. I recommend using [GNU Stow](https://www.gnu.org/software/stow/) for managing symlinks:

```bash
# Example: symlink nvim config
stow nvim
```

Or manually symlink specific configurations:

```bash
ln -s ~/.dotfiles/nvim ~/.config/nvim
```

## What's Included

### Neovim

A Lua-based Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management. Features include LSP support, autocompletion, fuzzy finding with Telescope, Treesitter syntax highlighting, Git integration, and a custom UI theme.

To install: `ln -s $(pwd)/nvim ~/.config/nvim` and launch Neovim. Plugins will install automatically.

## Planned Additions

Configurations I plan to add:

- **fzf** - Command-line fuzzy finder
- **bat** - Cat clone with syntax highlighting
- **ripgrep** - Fast search tool
- **lazygit** - Terminal UI for git
- **lazydocker** - Terminal UI for docker
- **git** - Version control configuration
- **yazi** - Terminal file manager
- **wezterm** - Terminal Emulator
- **claude-code** - AI-powered coding assistant
- **cursor-agent** - AI code editor
- **google-cli** - Google Cloud CLI
- tldr
- navi
- zoxide
- pass
- doppler
- jq
- (Wave?)
- posting (terminal postman)


## Contributing

These are my personal dotfiles, but feel free to fork and adapt them for your own use.

## License

[MIT](LICENSE)
