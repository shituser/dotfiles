vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.keymap.set('n', '<Leader>ev', ':e $MYVIMRC')
vim.keymap.set('n', '<Leader><space>', ':nohlsearch<Cr>')
vim.keymap.set('n', '<C-s>', ':w<cr>')

-- Move to splits with HJKL only
vim.keymap.set('n', '<c-J>', '<C-W><C-J>')
vim.keymap.set('n', '<c-K>', '<C-W><C-K>')
vim.keymap.set('n', '<c-H>', '<C-W><C-H>')
vim.keymap.set('n', '<c-L>', '<C-W><C-L>')

-- Maintain the cursor position when yanking a visual selection.
-- http://ddrscott.github.io/blog/2016/yank-without-jank/
vim.keymap.set('v', 'y', 'myy`y')
vim.keymap.set('v', 'Y', 'myY`y')

-- When text is wrapped, move by terminal rows, not lines, unless a count is provided.
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })

vim.keymap.set('i', ';;', '<Esc>A;<Esc>')
vim.keymap.set('i', ',,', '<Esc>A,<Esc>')

-- Disable annoying command line thing.
vim.keymap.set('n', 'q:', ':q<CR>')

-- Resize with arrows.
vim.keymap.set('n', '<C-Up>', ':resize +2<CR>')
vim.keymap.set('n', '<C-Down>', ':resize -2<CR>')
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>')
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>')


-- Call Lazy
vim.keymap.set('n', '<Leader>l', ':Lazy<CR>')
vim.keymap.set('n', '<Leader>m', ':Mason<CR>')
