# Neovim Configuration

Lua-based Neovim configuration using [lazy.nvim](https://github.com/folke/lazy.nvim) for plugin management.

## Features

- LSP support for multiple languages
- Autocompletion with nvim-cmp
- Fuzzy finding with Telescope
- Treesitter syntax highlighting
- Git integration with gitsigns and fugitive
- Custom Synthwave 2077 color scheme in lualine
- Transparent background support
- Seamless tmux integration with vim-tmux-navigator

## Shell Integration

Aliases configured in bash/zsh dotfiles:
- `v` - alias to nvim
- `vim` - alias to nvim
- `n()` - Smart nvim opener (opens current dir if no args)

## Installation

```bash
./install.sh nvim
```

Launch Neovim and plugins will install automatically.
