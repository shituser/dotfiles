require('tokyonight').setup({
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    functions = {},
  },
  on_highlights = function(hl, c)
    local prompt = "#2d3149"

    hl.SpellBad = {
      undercurl = true,
      sp = '#7F3A43',
    }

    hl.TelescopeNormal = { bg = c.bg_dark, fg = c.fg_dark }
    hl.TelescopeBorder = { bg = c.bg_dark, fg = c.bg_dark }
    hl.TelescopePromptNormal = { bg = prompt }
    hl.TelescopePromptBorder = { bg = prompt, fg = prompt }
    hl.TelescopePromptTitle = { bg = c.bg, fg = c.fg_dark }
    hl.TelescopePreviewTitle = { bg = c.bg_dark, fg = c.bg_dark }
    hl.TelescopeResultsTitle = { bg = c.bg_dark, fg = c.bg_dark }

    hl.StatusLineNonText = { bg = c.bg_dark, fg = c.fg_gutter }

    hl.IndentBlanklineChar = { fg = c.bg_highlight }

    hl.Floaterm = { bg = prompt }
    hl.FloatermBorder = { bg = prompt, fg = prompt }

    hl.CopilotSuggestion = { fg = c.comment }

    hl.NvimTreeIndentMarker = { fg = c.bg_highlight }
    hl.NvimTreeOpenedFile = { fg = c.fg, bold = true }


    -- Lazy UI
    local prompt = "#2d3149"
    hl.LazyNormal = { bg = prompt, fg = c.fg }
    hl.LazyBorder = { bg = prompt, fg = prompt }
    hl.NormalFloat = { bg = prompt, fg = c.fg }

    hl.LazyH1 = { fg = c.cyan, bold = true }
    hl.LazyH2 = { fg = c.blue }
    hl.LazyButton = { bg = c.bg_highlight, fg = c.fg }
    hl.LazyButtonActive = { bg = c.bg_highlight, fg = c.fg, bold = true }
    hl.LazyComment = { fg = c.comment, italic = true }
    hl.LazyProgressDone = { fg = c.green }
    hl.LazyProgressTodo = { fg = c.bg_highlight }

    hl.FloatShadow = { bg = "NONE" }
    hl.FloatShadowThrough = { bg = "NONE" }

  end,
})

vim.cmd.colorscheme('tokyonight-storm')
