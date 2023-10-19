-- Recompile Packer on file write
vim.cmd([[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end
]])

-- Highlight TODO's
vim.cmd([[
augroup vimrc_todo
  au!
  au Syntax * syn match MyTodo /(FIXME|TODO|OPTIMIZE|NOTE|fixme|todo|optimize|note)i/ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo
]])

-- Set tab and space width
vim.cmd([[
augroup autosourcing
  autocmd!
  autocmd BufWritePost init.lua source % " Auto source .vimrc

  autocmd Filetype blade setlocal shiftwidth=2 tabstop=2

  autocmd Filetype css setlocal shiftwidth=2 tabstop=2
  autocmd Filetype scss setlocal shiftwidth=2 tabstop=2

  autocmd Filetype html setlocal shiftwidth=2 tabstop=2
augroup END
]])
