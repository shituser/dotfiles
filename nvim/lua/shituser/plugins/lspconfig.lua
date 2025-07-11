require('mason').setup()
require('mason-lspconfig').setup({ automatic_installation = true })

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local on_attach = function(client, bufnr)
  require("tailwindcss-colors").buf_attach(bufnr)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end

local lspconfig = require('lspconfig')

lspconfig.intelephense.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.elixirls.setup({ on_attach = on_attach, capabilities = capabilities })
lspconfig.volar.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'javascript', 'vue' },
})
lspconfig.ts_ls.setup({
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = "/usr/local/lib/node_modules/@vue/typescript-plugin",
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = { "javascript", "typescript", "vue" },
  capabilities = capabilities,
})
lspconfig.jsonls.setup({
  capabilities = capabilities,
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
    },
  },
})
lspconfig.emmet_ls.setup({
  capabilities = capabilities,
  filetypes = { "css", "html", "blade", "javascript", "less", "sass", "scss", "svelte", "vue" },
})
lspconfig.tailwindcss.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "css", "html", "blade", "svelte", "vue" },
})

-- Keymaps
vim.keymap.set('n', '<Leader>d', '<cmd>lua vim.diagnostic.open_float()<CR>')
vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>')
vim.keymap.set('n', 'gd', ':Telescope lsp_definitions<CR>')
vim.keymap.set('n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>')
vim.keymap.set('n', 'gi', ':Telescope lsp_implementations<CR>')
vim.keymap.set('n', 'gr', ':Telescope lsp_references<CR>')
vim.keymap.set('n', 'gf', '<cmd>lua vim.lsp.buf.formatting()<CR>')
vim.keymap.set('n', '<Leader>lr', ':LspRestart<CR>', { silent = true })
vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
vim.keymap.set('n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>')

-- Commands
vim.api.nvim_create_user_command('Format', function()
  vim.lsp.buf.format({ timeout_ms = 5000 })
end, {})

-- Diagnostics
vim.diagnostic.config({ virtual_text = false, float = { source = true } })

-- Signs
vim.fn.sign_define('DiagnosticSignError', { text = '', texthl = 'DiagnosticSignError' })
vim.fn.sign_define('DiagnosticSignWarn',  { text = '', texthl = 'DiagnosticSignWarn' })
vim.fn.sign_define('DiagnosticSignInfo',  { text = '', texthl = 'DiagnosticSignInfo' })
vim.fn.sign_define('DiagnosticSignHint',  { text = '', texthl = 'DiagnosticSignHint' })
