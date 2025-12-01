# My Dotfiles

These are my personal dotfiles. I'm slowly building them up, so expect things to change.

## Neovim

My Neovim configuration is written in Lua and is managed by the [lazy.nvim](https.github.com/folke/lazy.nvim) plugin manager.

### Installation

1.  Clone this repository: `git clone https://github.com/nalhilal/dotfiles.git`
2.  Symlink the `nvim` directory: `ln -s $(pwd)/nvim ~/.config/nvim`
3.  Launch Neovim. The plugins will be installed automatically.

### Features

- **Plugin Management:** Using `lazy.nvim` for easy plugin management.
- **LSP:** Full LSP support for code intelligence.
- **Autocompletion:** Using `nvim-cmp` for autocompletion.
- **Telescope:** For fuzzy finding files, buffers, and more.
- **Treesitter:** For better syntax highlighting and code navigation.
- **Git Integration:** With `gitsigns.nvim`.
- **Beautiful UI:** With a custom theme, `lualine`, `bufferline`, and `alpha` (dashboard).

### Plugins

Here is a list of the plugins I'm currently using:

- **[alpha-nvim](https://github.com/goolord/alpha-nvim):** A dashboard for Neovim.
- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp):** Autocompletion plugin.
- **[null-ls.nvim](https://github.com/jose-elias-alvarez/null-ls.nvim):** for formatting and linting.
- **[nvim-bufferline.lua](https://github.com/akinsho/nvim-bufferline.lua):** A simple bufferline.
- **A custom colorscheme (colortheme.lua).**
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim):** Git integration.
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim):** Indentation guides.
- **[nvim-lspconfig](https://github.com/neovim/nvim-lspconfig):** LSP configurations.
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim):** A statusline for Neovim.
- **[neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim):** A file explorer.
- **[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim):** A fuzzy finder.
- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter):** Treesitter support.

### Keymaps

The main keymaps are defined in `lua/core/keymaps.lua`. The leader key is `<space>`.

_I will add more details about the keymaps later._

## License

[MIT](LICENSE)
