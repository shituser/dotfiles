local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

require('packer').reset()
require('packer').init({
    compile_path = vim.fn.stdpath('data')..'/site/plugin/packer_compiled.lua',
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'solid' })
        end,
    },
})

local use = require('packer').use

use 'wbthomason/packer.nvim'

-- Tokyo night color scheme
use({
    'folke/tokyonight.nvim',
    config = function()
        require('shituser/plugins/tokyonight')
    end
})

-- Comment stuff out. Use gcc to comment out a line (takes a count), gc to comment out the target of a motion (for example, gcap to comment out a paragraph), gc in visual mode to comment out the selection, and gc in operator pending mode to target a comment. You can also use it as a command, either with a range like :7,17Commentary, or as part of a :global invocation like with :g/TODO/Commentary. That's it.
use 'tpope/vim-commentary'

-- Surround.vim is all about "surroundings": parentheses, brackets, quotes, XML tags, and more. The plugin provides mappings to easily delete, change and add such surroundings in pairs.
-- cs"' Changes "Hello world" to 'Hello world'. cst" changes <h1>Hello world</h1> to "Hello world"
use 'tpope/vim-surround'

-- Indent autodetection
use 'tpope/vim-sleuth'

-- Allows using dot command to repeat actions from plugins
use 'tpope/vim-repeat'

-- Navigate seamlessly between Vim windows and Tmux panes.
use('christoomey/vim-tmux-navigator')

-- Jump to the last location when opening a file.
use('farmergreg/vim-lastplace')

-- Enable * searching with visually selected text.
use('nelstrom/vim-visual-star-search')

-- Automatically create parent dirs when saving.
use('jessarcher/vim-heritage')

-- Text objects for HTML attributes.
-- This vim plugin provides two text objects: ax and ix.
use({
  'whatyouhide/vim-textobj-xmlattr',
  requires = 'kana/vim-textobj-user',
})

-- Automatically add closing brackets, quotes, etc.
use {
    "windwp/nvim-autopairs",
    config = function() require("nvim-autopairs").setup {} end
}

-- Add smooth scrolling to avoid jarring jumps
use({
  'karb94/neoscroll.nvim',
  config = function()
    require('neoscroll').setup()
  end,
})

-- All closing buffers without closing the split window.
use({
  'famiu/bufdelete.nvim',
  config = function()
    vim.keymap.set('n', '<Leader>q', ':Bdelete<CR>')
    vim.keymap.set('n', '<Leader>Q', ':bufdo Bdelete<CR>')
  end,
})

-- Split arrays and methods onto multiple lines, or join them back up.
-- gS to split a one-liner into multiple lines
-- gJ (with the cursor on the first line of a block) to join a block into a single-line statement.
use({
  'AndrewRadev/splitjoin.vim',
  config = function()
    vim.g.splitjoin_html_attributes_bracket_on_new_line = 1
    vim.g.splitjoin_trailing_comma = 1
    vim.g.splitjoin_php_method_chain_full = 1
  end,
})

-- Automatically fix indentation when pasting code.
use({
  'sickill/vim-pasta',
  config = function()
    vim.g.pasta_disabled_filetypes = { 'fugitive' }
  end,
})

-- Fuzzy finder
use({
  'nvim-telescope/telescope.nvim',
  after = 'tokyonight.nvim',
  requires = {
    'nvim-lua/plenary.nvim',
    'kyazdani42/nvim-web-devicons',
    'nvim-telescope/telescope-live-grep-args.nvim',
    { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' },
  },
  config = function()
    require('shituser/plugins/telescope')
  end,
})

-- File tree sidebar
use({
  'kyazdani42/nvim-tree.lua',
  requires = 'kyazdani42/nvim-web-devicons',
  config = function()
    require('shituser/plugins/nvim-tree')
  end,
})

-- A Status line.
use({
  'nvim-lualine/lualine.nvim',
  after = 'tokyonight.nvim',
  requires = {
    'arkav/lualine-lsp-progress',
    'kyazdani42/nvim-web-devicons',
  },
  config = function()
    require('shituser/plugins/lualine')
  end,
})

-- Display hex color representations in Vim
use({
  'NvChad/nvim-colorizer.lua',
  config = function()
    require('colorizer').setup({
      user_default_options = {
        names = false,
      }
    })
  end,
})

-- Display indentation lines.
use({
  'lukas-reineke/indent-blankline.nvim',
  config = function()
    require('shituser/plugins/indent-blankline')
  end,
})

-- Git integration.
use({
  'lewis6991/gitsigns.nvim',
  config = function()
    require('gitsigns').setup({
      -- signs = {
      --   add = { text = '⢕' },
      --   change = { text = '⢕' },
      -- },
    })
    vim.keymap.set('n', ']h', ':Gitsigns next_hunk<CR>')
    vim.keymap.set('n', '[h', ':Gitsigns prev_hunk<CR>')
    vim.keymap.set('n', 'gs', ':Gitsigns stage_hunk<CR>')
    vim.keymap.set('n', 'gS', ':Gitsigns undo_stage_hunk<CR>')
    vim.keymap.set('n', 'gp', ':Gitsigns preview_hunk<CR>')
    vim.keymap.set('n', 'gb', ':Gitsigns blame_line<CR>')
  end,
})

--- Floating terminal.
use({
  'voldikss/vim-floaterm',
  config = function()
    vim.g.floaterm_height = 0.8
    vim.g.floaterm_width = 0.8
    vim.keymap.set('n', '<Leader>t', ':FloatermToggle<CR>')
    vim.keymap.set('t', '<Leader>t', '<C-\\><C-n>:FloatermToggle<CR>')
  end
})

-- Improved syntax highlighting
use({
  'nvim-treesitter/nvim-treesitter',
  run = function()
    require('nvim-treesitter.install').update({ with_sync = true })
  end,
  requires = {
    -- 'JoosepAlviste/nvim-ts-context-commentstring',
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  config = function()
    require('shituser/plugins/treesitter')
  end,
})

-- Language Server Protocol.
use({
  'neovim/nvim-lspconfig',
  requires = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'b0o/schemastore.nvim',
    'jose-elias-alvarez/null-ls.nvim',
    'jayp0521/mason-null-ls.nvim',
  },
  config = function()
    require('shituser/plugins/lspconfig')
  end,
})

-- Completion
use({
  'hrsh7th/nvim-cmp',
  requires = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lsp-signature-help',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'L3MON4D3/LuaSnip',
    'saadparwaiz1/cmp_luasnip',
    'onsails/lspkind-nvim',
  },
  config = function()
    require('shituser/plugins/cmp')
  end,
})

-- Automatically set up your configuration after cloning packer.nvim
-- Put this at the end after all plugins
if packer_bootstrap then
    require('packer').sync()
end
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
]])
