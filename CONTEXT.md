# Dotfiles Context

Last reviewed: 2026-03-23
Repo path: `/home/nikola/Public/dotfiles`

## Post-Review Updates

Current in-progress clipboard work:

- `tmux/tmux.conf` now disables tmux's own terminal clipboard protocol with `set -s set-clipboard off`
- `tmux/tmux.conf` routes copy/paste through repo-local helper scripts
- `tmux/scripts/clipboard-copy` and `tmux/scripts/clipboard-paste` now intentionally avoid `kitten clipboard` while running inside tmux
- The tmux helpers prefer concrete OS clipboard tools: `wl-copy`/`wl-paste`, `xclip`, `xsel`, then `pbcopy`/`pbpaste`
- If no concrete clipboard tool is installed, tmux shows a status message instead of attempting Kitty terminal clipboard transport
- `kitty/kitty.conf` enables clipboard integration with `clipboard_control write-clipboard write-primary read-clipboard read-primary`
- `nvim/lua/shituser/options.lua` only enables `clipboard=unnamedplus` when a concrete system clipboard backend exists

Observed risk and likely root cause:

- `wl-copy` and `wl-paste` are now installed (`wl-clipboard 2.0.0`)
- On the earlier failing setup, `kitten` existed but `wl-copy`, `wl-paste`, `xclip`, `xsel`, `pbcopy`, and `pbpaste` were not installed
- That meant Kitty terminal clipboard transport was the only available path
- Using that path from inside tmux is the likely tmux server crash vector for both tmux copy/paste bindings and Neovim clipboard usage
- With `wl-clipboard` installed, tmux helper scripts should now use Wayland clipboard directly and Neovim should enable `clipboard=unnamedplus` on startup

## Overview

This repo contains personal config for:

- `zsh`
- `tmux`
- `kitty`
- `neovim`

The working tree was clean when this context file was generated.

There are also two likely-non-active areas:

- `dotfiles.legacy/`: older archived configs
- `composer/`: only contains `composer/.htaccess`

## Top-Level Layout

- `install.sh`: bootstrap script that symlinks configs into `$HOME`
- `zsh/zshrc`: main shell config
- `tmux/tmux.conf`: tmux config
- `tmux/base16.sh`: tmux theme loader
- `tmux/scripts/tmux-spotify`: helper script on PATH
- `kitty/kitty.conf`: terminal config
- `kitty/current-theme.conf`: active Kitty theme include
- `nvim/init.lua`: Neovim entrypoint
- `nvim/lua/shituser/*`: active Neovim Lua config
- `nvim/after/lsp/vtsls.lua`: per-server LSP override for Vue/TypeScript
- `nvim/lazy-lock.json`: Lazy plugin lockfile
- `dotfiles.legacy/*`: old Vim/tmux/zsh setup kept for reference

## Bootstrap / Install Behavior

`install.sh` does the following:

1. Removes existing `$HOME/.zshrc` and symlinks `zsh/zshrc`
2. Removes existing `$HOME/.config/kitty` and symlinks `kitty/`
3. Removes existing `$HOME/.tmux.conf`
4. Removes `~/.tmux/plugins/tpm`
5. Clones `tmux-plugins/tpm`
6. Symlinks `tmux/tmux.conf` to `$HOME/.tmux.conf`
7. Removes existing `$HOME/.config/nvim`
8. Symlinks `nvim/`

Important note:

- The script is destructive for existing local config paths because it uses `rm -rf`
- It assumes network access for cloning TPM
- It does not install Oh My Zsh, NVM, Mason tools, Nerd Fonts, Kitty, or Neovim dependencies

## Zsh

Main file: `zsh/zshrc`

Current behavior:

- Loads NVM from `~/.nvm`
- Uses Oh My Zsh from `~/.oh-my-zsh`
- Theme: `robbyrussell`
- Plugins: only `git`
- Sources `~/.config/bw_session`
- Sources `~/.openai_key`

Aliases of note:

- `vi="nvim"`
- `tmux="tmux -2"`
- `art="php artisan"`
- `phpunit="vendor/bin/phpunit"`
- `kitty="~/.local/kitty.app/bin/kitty"`
- `ai="sgpt"`
- `aicom="git diff | sgpt 'Generate git commit message, for my changes'"`
- SSH aliases for specific hosts: `winston`, `rusko`
- `gpp`: pushes to several named git remotes

PATH additions:

- `$HOME/.config/composer/vendor/bin`
- Go: `/usr/local/go`, `$HOME/go/bin`
- `$HOME/.dotfiles/tmux/scripts`
- `$HOME/.local/lib/python3.10/site-packages`
- `$HOME/.local/bin`
- Fly.io: `$HOME/.fly/bin`

Notable quirks:

- Shell-GPT integration block is duplicated
- `PATH` references `$HOME/.dotfiles/tmux/scripts`, but this repo currently lives at `/home/nikola/Public/dotfiles`
- The shell config depends on local secret/session files that are not in this repo

## Tmux

Main file: `tmux/tmux.conf`

Current behavior:

- Default shell is `/bin/zsh`
- Prefix is remapped from `Ctrl-b` to `Ctrl-a`
- Window and pane indexes start at `1`
- Mouse support is enabled
- Vi-style copy mode is enabled
- History limit is `20000`
- Windows are renumbered automatically
- Aggressive resize is enabled

Key bindings of note:

- `prefix + r`: reload config
- `prefix + |` / `prefix + -`: split using current pane path
- `prefix + h/j/k/l`: move between panes
- `prefix + H/J/K/L`: resize panes
- `prefix + =`: tiled layout
- `prefix + y`: synchronize panes
- `prefix + C-h` / `prefix + C-l`: previous/next window

Clipboard integration:

- Uses `reattach-to-user-namespace pbcopy/pbpaste`
- This is macOS-oriented and may not work on Linux without replacement

Theme/plugins:

- Dynamically resolves the config directory and sources `tmux/base16.sh`
- TPM plugins:
  - `tmux-plugins/tpm`
  - `tmux-plugins/tmux-resurrect`
  - `pwittchen/tmux-plugin-spotify`

## Kitty

Main file: `kitty/kitty.conf`

Current behavior:

- Uses JetBrainsMono Nerd Font variants on Linux
- Font size: `13`
- Window decorations hidden
- Initial size: `2560x1440`
- Line height increased to `200%`
- Block cursor, no cursor blink
- Audio bell disabled
- Window padding width `5`
- Theme is included from `kitty/current-theme.conf`

Active theme:

- Catppuccin Macchiato

Extra file:

- `kitty/kitty.conf.bak` exists as a backup copy

## Neovim

Entrypoint:

- `nvim/init.lua`

Active modules loaded at startup:

- `shituser.options`
- `shituser.keymap`
- `shituser.autocmd`
- `shituser.lazy`

Important distinction:

- `nvim/lua/shituser/lazy.lua` is the active plugin manager setup
- `nvim/lua/shituser/plugins.lua` is an older Packer-based config and is not loaded by `init.lua`

### Core Editor Defaults

From `nvim/lua/shituser/options.lua`:

- 4-space default indentation
- Relative line numbers
- Mouse enabled
- Spellcheck enabled
- Languages: `en_us,bg`
- Case-insensitive search with smartcase
- No wrapping
- Persistent undo enabled
- Backups enabled
- Clipboard uses `unnamedplus`
- Signcolumn fixed to `yes:2`
- GUI colors enabled

Autocommands from `nvim/lua/shituser/autocmd.lua`:

- Highlights TODO/FIXME/NOTE-style comments
- Trims trailing whitespace on save
- Sets 2-space indentation for web/Lua-related filetypes
- Runs `vim.lsp.buf.format({ async = false })` on every save and restores cursor position

Keymaps from `nvim/lua/shituser/keymap.lua`:

- Leader: space
- `<Leader>l`: open Lazy
- `<Leader>m`: open Mason
- `<Leader>ev`: edit init file
- `<Leader><space>`: clear search highlighting
- `<C-s>`: save
- `<C-h/j/k/l>`: move between splits
- `<C-Up/Down/Left/Right>`: resize splits
- Insert helpers: `;;` and `,,` append punctuation at line end

### Plugin Manager State

Active manager:

- `folke/lazy.nvim`

Lockfile:

- `nvim/lazy-lock.json`

The repo still contains an older Packer config:

- `nvim/lua/shituser/plugins.lua`

That older file appears stale and includes references not present in the active runtime, including a missing `require('shituser/plugins/tsblade')`.

### Active Neovim Plugins

Key active plugin groups from `nvim/lua/shituser/lazy.lua`:

- Theme: `catppuccin/nvim`
- Telescope and extensions
- `nvim-tree`
- `lualine`
- `gitsigns`
- `floaterm`
- Treesitter + textobjects
- LSP stack with Mason
- `none-ls` for formatting through `prettierd`
- `nvim-cmp` + LuaSnip
- `phpactor`
- `centerpad.nvim`
- `tabular`
- `tailwindcss-colors.nvim`
- Several tpope/Vim utility plugins

Theme status:

- Active colorscheme is Catppuccin Macchiato
- `tokyonight.lua` still exists but is not currently active

### LSP / Formatting

From `nvim/lua/shituser/plugins/lspconfig.lua`:

Managed servers:

- `tailwindcss`
- `emmet_ls`
- `intelephense`
- `jsonls`
- `elixirls`
- `vtsls`
- `vue_ls`

Extra tooling:

- Mason installs `prettierd`
- `none-ls` uses `prettierd` for formatting web-related filetypes, including `blade`

LSP/UI keymaps:

- `gd`: definitions through Telescope
- `gi`: implementations
- `gr`: references
- `ga`: code actions
- `gf`: format
- `K`: hover
- `<Leader>rn`: rename
- `<Leader>d`, `[d`, `]d`: diagnostics
- `<Leader>lr`: restart LSP

Vue/TypeScript detail:

- `nvim/after/lsp/vtsls.lua` configures the Vue TypeScript plugin from the Mason-installed Vue language server path

Operational implication:

- The Neovim setup expects local external tools such as `git`, `make`, `composer`, language servers installed via Mason, and likely Node/npm support for some language tooling

### Telescope / Tree / UI Notes

Telescope:

- Hidden files shown in `find_files`
- `.git/` ignored
- `fzf` and `live_grep_args` extensions are loaded

Nvim-tree:

- Git ignored files are still shown
- Hides `.ide.php` and `.git`
- `<Leader>n` toggles/focuses current file in tree
- Auto-quits Neovim if NvimTree is the last remaining window

Lualine:

- Uses Catppuccin theme
- Shows mode, git info, diagnostics, LSP client count, file info, cursor position

## Legacy Archive

`dotfiles.legacy/` appears to be an archived pre-Lua or older-generation setup:

- `dotfiles.legacy/nvim/init.vim`
- old colorschemes and UltiSnips
- old tmux config/theme files
- old zsh config

Treat this directory as reference material, not current source of truth, unless explicitly reviving something from it.

## External Dependencies / Assumptions

This repo assumes the environment already has most of the following:

- `zsh`
- Oh My Zsh
- `nvim`
- `kitty`
- `tmux`
- `git`
- Nerd Font matching the Kitty/tmux/Neovim glyph usage
- `reattach-to-user-namespace` if tmux clipboard config is kept as-is
- NVM / Node.js
- Go
- `sgpt`
- Composer / PHP toolchain
- Mason-managed LSP servers and tools

## Mismatches And Risks To Remember

- `install.sh` deletes existing config targets before linking
- `zsh/zshrc` still references `$HOME/.dotfiles/tmux/scripts`, which does not match this repo location
- `zsh/zshrc` contains duplicated Shell-GPT setup
- tmux clipboard commands are macOS-specific
- The repo contains both active Lazy-based Neovim config and stale Packer-era config
- `nvim/lua/shituser/plugins.lua` should not be treated as authoritative unless the startup flow changes

## Source Of Truth For Future Work

When modifying this repo later, prefer these files first:

- `install.sh`
- `zsh/zshrc`
- `tmux/tmux.conf`
- `kitty/kitty.conf`
- `kitty/current-theme.conf`
- `nvim/init.lua`
- `nvim/lua/shituser/lazy.lua`
- `nvim/lua/shituser/options.lua`
- `nvim/lua/shituser/keymap.lua`
- `nvim/lua/shituser/autocmd.lua`
- `nvim/lua/shituser/plugins/*.lua`
- `nvim/after/lsp/vtsls.lua`

Treat these as secondary/stale unless proven otherwise:

- `dotfiles.legacy/**`
- `nvim/lua/shituser/plugins.lua`
- `kitty/kitty.conf.bak`
