local augroup = vim.api.nvim_create_augroup   -- Create/get autocommand group
local autocmd = vim.api.nvim_create_autocmd   -- Create autocommand

-- Recompile Packer on file write
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
]])

-- Highlight TODO's
vim.cmd([[
augroup vim_todo
  au!
  au Syntax * syn match MyTodo /(FIXME|TODO|OPTIMIZE|NOTE|fixme|todo|optimize|note)i/ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo
]])

-- Remove whitespace on save
autocmd('BufWritePre', {
  pattern = '',
  command = ":%s/\\s\\+$//e"
})

-- Set indentation to 2 spaces
augroup('setIndent', { clear = true })
autocmd('Filetype', {
  group = 'setIndent',
  pattern = { 'xml', 'html', 'xhtml', 'css', 'scss', 'javascript', 'typescript', 'yaml', 'lua', 'blade' },
  command = 'setlocal shiftwidth=2 tabstop=2'
})
