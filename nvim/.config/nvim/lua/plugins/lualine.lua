-- Set lualine as statusline
return {
  'nvim-lualine/lualine.nvim',
  config = function()
    -- Synthwave 2077 color palette
    local synthwave_colors = {
      pink = '#ff7edb',
      purple = '#b893ce',
      cyan = '#72f1b8',
      neon_green = '#fede5d',
      bg = '#262335',
      fg = '#f8f8f2',
      gray1 = '#848bbd',
      gray2 = '#2a273f',
      gray3 = '#393552',
    }

    local synthwave_theme = {
      normal = {
        a = { fg = synthwave_colors.bg, bg = synthwave_colors.cyan, gui = 'bold' },
        b = { fg = synthwave_colors.fg, bg = synthwave_colors.gray3 },
        c = { fg = synthwave_colors.fg, bg = synthwave_colors.gray2 },
      },
      command = { a = { fg = synthwave_colors.bg, bg = synthwave_colors.neon_green, gui = 'bold' } },
      insert = { a = { fg = synthwave_colors.bg, bg = synthwave_colors.pink, gui = 'bold' } },
      visual = { a = { fg = synthwave_colors.bg, bg = synthwave_colors.purple, gui = 'bold' } },
      terminal = { a = { fg = synthwave_colors.bg, bg = synthwave_colors.cyan, gui = 'bold' } },
      replace = { a = { fg = synthwave_colors.bg, bg = synthwave_colors.pink, gui = 'bold' } },
      inactive = {
        a = { fg = synthwave_colors.gray1, bg = synthwave_colors.bg, gui = 'bold' },
        b = { fg = synthwave_colors.gray1, bg = synthwave_colors.bg },
        c = { fg = synthwave_colors.gray1, bg = synthwave_colors.gray2 },
      },
    }

    -- OneDark color palette (legacy)
    local onedark_colors = {
      blue = '#61afef',
      green = '#98c379',
      purple = '#c678dd',
      cyan = '#56b6c2',
      red1 = '#e06c75',
      red2 = '#be5046',
      yellow = '#e5c07b',
      fg = '#abb2bf',
      bg = '#282c34',
      gray1 = '#828997',
      gray2 = '#2c323c',
      gray3 = '#3e4452',
    }

    local onedark_theme = {
      normal = {
        a = { fg = onedark_colors.bg, bg = onedark_colors.green, gui = 'bold' },
        b = { fg = onedark_colors.fg, bg = onedark_colors.gray3 },
        c = { fg = onedark_colors.fg, bg = onedark_colors.gray2 },
      },
      command = { a = { fg = onedark_colors.bg, bg = onedark_colors.yellow, gui = 'bold' } },
      insert = { a = { fg = onedark_colors.bg, bg = onedark_colors.blue, gui = 'bold' } },
      visual = { a = { fg = onedark_colors.bg, bg = onedark_colors.purple, gui = 'bold' } },
      terminal = { a = { fg = onedark_colors.bg, bg = onedark_colors.cyan, gui = 'bold' } },
      replace = { a = { fg = onedark_colors.bg, bg = onedark_colors.red1, gui = 'bold' } },
      inactive = {
        a = { fg = onedark_colors.gray1, bg = onedark_colors.bg, gui = 'bold' },
        b = { fg = onedark_colors.gray1, bg = onedark_colors.bg },
        c = { fg = onedark_colors.gray1, bg = onedark_colors.gray2 },
      },
    }

    -- Import color theme based on environment variable NVIM_THEME
    local env_var_nvim_theme = os.getenv 'NVIM_THEME' or 'synthwave'

    -- Define a table of themes
    local themes = {
      synthwave = synthwave_theme,
      onedark = onedark_theme,
      nord = 'nord',
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local mode = {
      'mode',
      fmt = function(str)
        if hide_in_width() then
          return ' ' .. str
        else
          return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
        end
      end,
    }

    local filename = {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 0, -- 0 = just filename, 1 = relative path, 2 = absolute path
    }

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
      cond = hide_in_width,
    }

    require('lualine').setup {
      options = {
        icons_enabled = true,
        theme = themes[env_var_nvim_theme], -- Set theme based on environment variable
        -- Some useful glyphs:
        -- https://www.nerdfonts.com/cheat-sheet
        --        
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
        disabled_filetypes = { 'alpha', 'neo-tree', 'Avante' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        lualine_c = { filename },
        lualine_x = { diagnostics, diff, { 'encoding', cond = hide_in_width }, { 'filetype', cond = hide_in_width } },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
