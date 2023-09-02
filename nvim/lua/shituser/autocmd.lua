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
  au Syntax * syn match MyTodo /(FIXME|TODO|OPTIMIZE|NOTE)i/ containedin=.*Comment,vimCommentTitle
augroup END
hi def link MyTodo Todo
]])

-- Set tab and space width
vim.cmd([[
augroup autosourcing
	autocmd!
	autocmd Filetype blade setlocal ts=2
	autocmd Filetype blade setlocal sw=2

	autocmd Filetype css setlocal ts=2
	autocmd Filetype scss setlocal ts=2
	autocmd Filetype html setlocal ts=2
	autocmd Filetype javascript setlocal ts=4

	autocmd Filetype css setlocal sw=2
	autocmd Filetype scss setlocal sw=2
	autocmd Filetype html setlocal sw=2
	autocmd Filetype javascript setlocal sw=4
augroup END
]])
