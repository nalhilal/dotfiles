-- Thanks to Henry for an amazing video and his dotfiles at: https://github.com/hendrikmi/dotfiles/tree/main/nvim
require 'core.options' -- Load general options
require 'core.keymaps' -- Load general keymaps
-- require 'core.snippets' -- Custom code snippets
-- require 'tools.sql-runner'

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Import color theme based on environment variable NVIM_THEME
local default_color_scheme = 'synthwave'
local env_var_nvim_theme = os.getenv 'NVIM_THEME' or default_color_scheme

-- Define a table of theme modules
local themes = {
  --  nord = 'plugins.themes.nord',
  --  onedark = 'plugins.themes.onedark',
  myNord = 'plugins.colortheme',
}

local plugins = {
  require 'plugins.telescope',
  require 'plugins.treesitter',
  require 'plugins.lsp',
  require 'plugins.autocompletion',
  require 'plugins.none-ls',
  require 'plugins.lualine',
  require 'plugins.bufferline',
  require 'plugins.neotree',
  --  require 'plugins.oil',
  require 'plugins.alpha',
  require 'plugins.indent-blankline',
  --  require 'plugins.lazygit',
  --  require 'plugins.comment',
  --  require 'plugins.debug',
  require 'plugins.gitsigns',
  --  require 'plugins.database',
  require 'plugins.misc',
  --  require 'plugins.harpoon',
  --  require 'plugins.avante',
  --  require 'plugins.aerial',
  require 'plugins.vim-tmux-navigator',
  require 'plugins.which-key',
}

if themes[env_var_nvim_theme] then
  table.insert(plugins, require(themes[env_var_nvim_theme]))
end

-- Setup plugins
require('lazy').setup(plugins, {
  ui = {
    -- If you have a Nerd Font, set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

if env_var_nvim_theme == 'synthwave' then
  vim.cmd.colorscheme 'synthwave'
end

-- Function to check if a file exists
local function file_exists(file)
  local f = io.open(file, 'r')
  if f then
    f:close()
    return true
  else
    return false
  end
end

-- Path to the session file
local session_file = '.session.vim'

-- Check if the session file exists in the current directory
if file_exists(session_file) then
  -- Source the session file
  vim.cmd('source ' .. session_file)
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
