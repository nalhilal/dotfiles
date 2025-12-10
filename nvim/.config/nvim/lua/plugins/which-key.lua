return {
  -- Hints keybinds
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    delay = 1000,
    preset = 'helix',

    -- top-level group names
    defaults = {
      ['<leader>g'] = { group = '+git' },
      ['<leader>f'] = { group = '+file' },
      ['<leader>t'] = { group = '+tabs' },
    },
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show { global = false }
      end,
      desc = 'Buffer Local Keymaps (which-key)',
    },
  },
}
