vim.opt.termguicolors = true

vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a' -- enable mouse for all modes

vim.opt.spell = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.wrap = false
vim.opt.breakindent = true -- maintain indent when wrapping indented lines

vim.opt.list = true -- enable the below listchars
vim.opt.listchars = { tab = '▸ ', trail = '·' }
vim.opt.fillchars:append({ eob = ' ' }) -- remove the ~ from end of buffer

vim.opt.splitbelow = true
vim.opt.splitright = true

--vim.opt.scrolloff = 8 -- Keeps cursor "in the center" when scrolling
--vim.opt.sidescrolloff = 8

local has_system_clipboard =
  (vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1)
  or vim.fn.executable('xclip') == 1
  or vim.fn.executable('xsel') == 1
  or (vim.fn.executable('pbcopy') == 1 and vim.fn.executable('pbpaste') == 1)

if has_system_clipboard then
  vim.opt.clipboard = 'unnamedplus'
end

vim.opt.confirm = true -- ask for confirmation instead of erroring
vim.opt.undofile = true -- persistent undo

vim.opt.backup = true -- automatically save a backup file
vim.opt.backupdir:remove('.') -- keep backups out of the current directory
vim.opt.shortmess:append({ I = true }) -- disable the splash screen

vim.opt.wildmode = 'longest:full,full' -- complete the longest common match, and allow tabbing the results to fully complete them
vim.opt.completeopt = 'menuone,longest,preview' -- always show menu in completions suggestions, even if one item;
vim.opt.signcolumn = 'yes:2'
vim.opt.showmode = false
--vim.opt.updatetime = 4001 -- Set updatime to 1ms longer than the default to prevent polyglot from changing it
--vim.opt.redrawtime = 10000 -- Allow more time for loading syntax on large files
--vim.opt.exrc = true
--vim.opt.secure = true

-- Set spelling on and dictionaries to English and Bulgarian
vim.opt.spelllang = 'en_us,bg'
vim.opt.spell = true
