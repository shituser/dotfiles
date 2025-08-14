-- local separator = { '"▏"', color = 'StatusLineNonText' }
--
-- require('lualine').setup({
--   options = {
--     section_separators = '',
--     component_separators = '',
--     globalstatus = true,
--     theme = {
--       normal = {
--         a = 'StatusLine',
--         b = 'StatusLine',
--         c = 'StatusLine',
--       },
--     },
--   },
--   sections = {
--     lualine_a = {
--       'mode',
--       separator,
--     },
--     lualine_b = {
--       'branch',
--       'diff',
--       separator,
--       function ()
--         return ' ' .. vim.pesc(tostring(#vim.tbl_keys(vim.lsp.get_clients())) or '')
--       end,
--       { 'diagnostics', sources = { 'nvim_diagnostic' } },
--       separator,
--     },
--     lualine_c = {
--       'filename'
--     },
--     lualine_x = {
--       'filetype',
--       'encoding',
--       'fileformat',
--     },
--     lualine_y = {
--       separator,
--       '(vim.bo.expandtab and "␠ " or "⇥ ") .. " " .. vim.bo.shiftwidth',
--       separator,
--     },
--     lualine_z = {
--       'location',
--       'progress',
--     },
--   },
-- })
local separator = { "▏" }

-- Взимаме lualine цветовете директно от Catppuccin
local catppuccin_theme = require("lualine.themes.catppuccin")
-- Ако искаш да пипнеш нюансите за macchiato, можеш тук:
-- catppuccin_theme.normal.a.bg = "#color"
-- catppuccin_theme.insert.a.bg = "#color"

require("lualine").setup({
  options = {
    section_separators = { left = "", right = "" },
    component_separators = "",
    globalstatus = true,
    theme = catppuccin_theme, -- 👈 вместо ръчното theme = { normal = ... }
  },
  sections = {
    lualine_a = {
      "mode",
      separator,
    },
    lualine_b = {
      "branch",
      "diff",
      separator,
      function()
        return " " .. vim.pesc(tostring(#vim.tbl_keys(vim.lsp.get_clients())) or "")
      end,
      { "diagnostics", sources = { "nvim_diagnostic" } },
      separator,
    },
    lualine_c = {
      "filename",
    },
    lualine_x = {
      "filetype",
      "encoding",
      "fileformat",
    },
    lualine_y = {
      separator,
      '(vim.bo.expandtab and "␠ " or "⇥ ") .. " " .. vim.bo.shiftwidth',
      separator,
    },
    lualine_z = {
      "location",
      "progress",
    },
  },
})

