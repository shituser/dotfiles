require("catppuccin").setup({
  flavour = "macchiato", -- latte, frappe, macchiato, mocha
  styles = {
    comments = {"italic"},
    keywords = {"italic"},
    functions = {},
  },
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = {
      enabled = true,
      show_root = true,
      transparent_panel = true,     -- true ако искаш прозрачен сайдбар
    },
    treesitter = true,
    notify = false,
    mini = {
      enabled = true,
      indentscope_color = "",
    },
    },
  custom_highlights = function(colors)
    local prompt = "#2d3149"

    return {
      -- ✅ SPELLING
      SpellBad = { undercurl = true, sp = "#7F3A43" },

      -- ✅ TELESCOPE
      TelescopeNormal        = { bg = colors.base, fg = colors.overlay0 },
      TelescopeBorder        = { bg = colors.base, fg = colors.base },
      TelescopePromptNormal  = { bg = prompt },
      TelescopePromptBorder  = { bg = prompt, fg = prompt },
      TelescopePromptTitle   = { bg = colors.mantle, fg = colors.overlay0 },
      TelescopePreviewTitle  = { bg = colors.base, fg = colors.base },
      TelescopeResultsTitle  = { bg = colors.base, fg = colors.base },

      -- ✅ STATUS LINE
      StatusLineNonText      = { bg = colors.base, fg = colors.surface1 },

      -- ✅ INDENT BLANKLINE
      IndentBlanklineChar    = { fg = colors.surface0 },

      -- ✅ FLOATERM
      Floaterm               = { bg = prompt },
      FloatermBorder         = { bg = prompt, fg = prompt },

      -- ✅ GITHUB COPILOT
      CopilotSuggestion      = { fg = colors.overlay1 },

      -- ✅ NVIM TREE
      NvimTreeIndentMarker   = { fg = colors.surface0 },
      NvimTreeOpenedFile     = { fg = colors.text, bold = true },
      NvimTreeNormal       = { bg = colors.base, fg = colors.text },
      NvimTreeNormalNC     = { bg = colors.base, fg = colors.text },
      NvimTreeWinSeparator = { fg = colors.base, bg = colors.base },
      NvimTreeEndOfBuffer  = { fg = colors.base, bg = colors.base },

      -- ✅ LAZY.NVIM UI
      LazyNormal             = { bg = prompt, fg = colors.text },
      LazyBorder             = { bg = prompt, fg = prompt },
      NormalFloat            = { bg = prompt, fg = colors.text },

      LazyH1                 = { fg = colors.sky, bold = true },
      LazyH2                 = { fg = colors.blue },
      LazyButton             = { bg = colors.surface0, fg = colors.text },
      LazyButtonActive       = { bg = colors.surface0, fg = colors.text, bold = true },
      LazyComment            = { fg = colors.overlay1, italic = true },
      LazyProgressDone       = { fg = colors.green },
      LazyProgressTodo       = { fg = colors.surface0 },

      -- ✅ FLOAT SHADOWS
      FloatShadow            = { bg = "NONE" },
      FloatShadowThrough     = { bg = "NONE" },
    }
  end,
})

vim.cmd.colorscheme("catppuccin-macchiato")
