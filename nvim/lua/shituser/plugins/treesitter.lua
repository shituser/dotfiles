require('nvim-treesitter.configs').setup({
  ensure_installed = {
    "lua", "php", "javascript", "html", "css", "vue", "elixir", "blade", "heex"
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ['if'] = '@function.inner',
        ['af'] = '@function.outer',
        ['ia'] = '@parameter.inner',
        ['aa'] = '@parameter.outer',
      },
    }
  },
})
