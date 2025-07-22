-- Bootstrap Lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Цветова схема
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require('shituser/plugins/tokyonight')
    end
  },

  -- tpope колекция
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "tpope/vim-sleuth" },
  { "tpope/vim-repeat" },
  { "tpope/vim-eunuch" },

  -- Други малки полезни
  { "christoomey/vim-tmux-navigator" },
  { "farmergreg/vim-lastplace" },
  { "nelstrom/vim-visual-star-search" },
  { "jessarcher/vim-heritage" },
  {
    "whatyouhide/vim-textobj-xmlattr",
    dependencies = { "kana/vim-textobj-user" }
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup {}
    end
  },
  {
    "karb94/neoscroll.nvim",
    config = function()
      require("neoscroll").setup()
    end
  },
  {
    "famiu/bufdelete.nvim",
    config = function()
      vim.keymap.set('n', '<Leader>q', ':Bdelete<CR>')
      vim.keymap.set('n', '<Leader>Q', ':bufdo Bdelete<CR>')
    end
  },
  {
    "AndrewRadev/splitjoin.vim",
    config = function()
      vim.g.splitjoin_html_attributes_bracket_on_new_line = 1
      vim.g.splitjoin_trailing_comma = 1
      vim.g.splitjoin_php_method_chain_full = 1
    end
  },
  {
    "sickill/vim-pasta",
    config = function()
      vim.g.pasta_disabled_filetypes = { 'fugitive' }
    end
  },

  -- Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "kyazdani42/nvim-web-devicons",
      "nvim-telescope/telescope-live-grep-args.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require('shituser/plugins/telescope')
    end
  },

  -- File tree
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = "kyazdani42/nvim-web-devicons",
    config = function()
      require('shituser/plugins/nvim-tree')
    end
  },

  {
    "nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup({
        override_by_extension = {
          ["blade.php"] = {
            icon = '',
            color = "#F05340",
            name = "Blade"
          }
        }
      })
    end
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "arkav/lualine-lsp-progress",
      "kyazdani42/nvim-web-devicons"
    },
    config = function()
      require('shituser/plugins/lualine')
    end
  },

  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({ user_default_options = { names = false } })
    end
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require('shituser/plugins/indent-blankline')
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup()
      vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>')
      vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>')
      vim.keymap.set('n', 'gs', ':Gitsigns stage_hunk<CR>')
      vim.keymap.set('n', 'gS', ':Gitsigns undo_stage_hunk<CR>')
      vim.keymap.set('n', 'gp', ':Gitsigns preview_hunk<CR>')
      vim.keymap.set('n', 'gb', ':Gitsigns blame_line<CR>')
    end
  },

  {
    "voldikss/vim-floaterm",
    config = function()
      vim.g.floaterm_height = 0.8
      vim.g.floaterm_width = 0.8
      vim.keymap.set('n', '<Leader>t', ':FloatermToggle<CR>')
      vim.keymap.set('t', '<Leader>t', '<C-\\><C-n>:FloatermToggle<CR>')
    end
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      "JoosepAlviste/nvim-ts-context-commentstring",
      "nvim-treesitter/nvim-treesitter-textobjects"
    },
    config = function()
      require('shituser/plugins/treesitter')
    end
  },

  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "b0o/schemastore.nvim",
    },
    config = function()
      require('shituser/plugins/lspconfig')
    end
  },

  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettierd,
        },
      })
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "onsails/lspkind-nvim"
    },
    config = function()
      require('shituser/plugins/cmp')
    end
  },

  {
    "phpactor/phpactor",
    ft = "php",
    build = "composer install --no-dev --optimize-autoloader",
    config = function()
      vim.keymap.set('n', '<Leader>pm', ':PhpactorContextMenu<CR>')
    end
  },

  {
    "smithbm2316/centerpad.nvim",
    config = function()
      vim.keymap.set('n', '<Leader>w', ':Centerpad<CR>')
    end
  },

  {
    "godlygeek/tabular",
    config = function()
      vim.keymap.set('n', '<Leader>a=', ':Tabularize /=><CR>')
      vim.keymap.set('v', '<Leader>a=', ':Tabularize /=><CR>')
      vim.keymap.set('n', '<Leader>a:', ":Tabularize /:\\zs<CR>")
      vim.keymap.set('v', '<Leader>a:', ":Tabularize /:\\zs<CR>")
    end
  },

  {
    "themaxmarchuk/tailwindcss-colors.nvim",
    config = function()
      require("tailwindcss-colors").setup()
    end
  }
}, {
  ui = {
    backdrop = 100
  }
})
