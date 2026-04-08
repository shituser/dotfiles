require('tokyonight').setup({
  style = 'storm',
  transparent = false,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    sidebars = 'dark',
    floats = 'dark',
  },
  sidebars = { 'qf', 'help', 'NvimTree', 'terminal', 'packer' },
  on_highlights = function(hl, c)
    hl.TelescopeNormal = {
      bg = c.bg_dark,
      fg = c.fg_dark,
    }
    hl.TelescopeBorder = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.TelescopePromptNormal = {
      bg = c.bg_highlight,
    }
    hl.TelescopePromptBorder = {
      bg = c.bg_highlight,
      fg = c.bg_highlight,
    }
    hl.TelescopePromptTitle = {
      bg = c.orange,
      fg = c.bg_dark,
    }
    hl.TelescopePreviewTitle = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.TelescopeResultsTitle = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.NormalFloat = {
      bg = c.bg_dark,
    }
    hl.FloatBorder = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
    hl.Floaterm = {
      bg = c.bg_dark,
    }
    hl.FloatermBorder = {
      bg = c.bg_dark,
      fg = c.bg_dark,
    }
  end,
})

vim.cmd.colorscheme('tokyonight-storm')
