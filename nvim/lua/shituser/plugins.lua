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
    --display = {
    --open_fn = function()
    --return require('packer.util').float({ border = 'solid' })
    --end,
    --},
})

local use = require('packer').use

use 'wbthomason/packer.nvim'

-- Toky night color scheme
use({
    'folke/tokyonight.nvim'
    -- 'folke/tokyonight.nvim',
    -- config = function()
    --   require('shituser/plugins/tokyonight')
    -- end,
})
vim.cmd[[colorscheme tokyonight]]

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
