# Dotfiles Context

Last reviewed: 2026-04-05
Repo path: `/home/nikola/Public/dotfiles`

## Overview

This repo contains the active personal setup for:

- `zsh`
- `tmux`
- `kitty`
- `neovim`

Stale config was removed on 2026-04-05:

- archived `dotfiles.legacy/`
- inactive Packer-based Neovim config
- old Tokyonight Neovim module
- `kitty/kitty.conf.bak`

## Top-Level Layout

- `install.sh`: bootstrap script — installs tools and symlinks configs into `$HOME`
- `zsh/zshrc`: main shell config (platform-agnostic)
- `zsh/linux.zsh`: Linux-specific PATH exports (Go, Python, Fly.io, .local/bin)
- `zsh/macos.zsh`: macOS-specific PATH exports (Homebrew, Go, Fly.io)
- `zsh/platform.zsh`: symlink created by `install.sh` → points to `linux.zsh` or `macos.zsh`
- `zsh/local.zsh`: gitignored machine-local overrides (SSH aliases, tokens, etc.)
- `zsh/local.zsh.example`: template for `local.zsh`
- `tmux/tmux.conf`: tmux config
- `tmux/base16.sh`: tmux theme loader (uses `if-shell` for OS-specific status bar)
- `tmux/scripts/clipboard-copy`: tmux-to-system clipboard helper
- `tmux/scripts/clipboard-paste`: system-to-tmux clipboard helper
- `tmux/scripts/now-playing`: playerctl-based music status for tmux status bar
- `kitty/kitty.conf`: terminal config (platform-agnostic; includes `platform.conf`)
- `kitty/linux.conf`: Linux font/display settings (Wayland, NF font names, size 13)
- `kitty/macos.conf`: macOS font settings (Nerd Font Mono names, size 16)
- `kitty/platform.conf`: symlink created by `install.sh` → points to `linux.conf` or `macos.conf`
- `kitty/current-theme.conf`: active Kitty theme include
- `kitty/Ayu Mirage.conf`: alternate Kitty theme file kept in repo
- `nvim/init.lua`: Neovim entrypoint
- `nvim/lua/shituser/*`: active Neovim Lua config
- `nvim/after/lsp/vtsls.lua`: per-server Vue/TypeScript override
- `nvim/lazy-lock.json`: Lazy plugin lockfile
- `composer/.htaccess`: unrelated leftover; not part of the active terminal/editor setup

## Bootstrap / Install Behavior

`install.sh` is a full bootstrap script. It detects the OS (`uname`) and:

1. **Installs packages** (OS-dispatched):
   - Linux (apt/Ubuntu): zsh, tmux, git, curl, ripgrep, fd-find, playerctl, wl-clipboard, xclip, php-cli, composer; Neovim from `ppa:neovim-ppa/unstable`; Kitty from official installer; JetBrainsMono Nerd Font from nerd-fonts releases; Go from golang.org
   - macOS (Homebrew): tmux, neovim, zsh, git, ripgrep, fd, go; Kitty and JetBrainsMono Nerd Font via cask; Composer via curl installer
2. Installs NVM (idempotent — skips if `~/.nvm` exists)
3. Installs Oh My Zsh (idempotent — skips if `~/.oh-my-zsh` exists)
4. Creates platform symlinks: `kitty/platform.conf` → `kitty/{os}.conf`, `zsh/platform.zsh` → `zsh/{os}.zsh`
5. Symlinks configs into `$HOME` (destructive: uses `rm -f`/`rm -rf` on existing targets)
6. Clones TPM to `~/.tmux/plugins/tpm`

Notes:

- The config symlinking step is intentionally destructive
- Network access is required for package installation and TPM clone
- Mason-managed LSP tools and language runtimes beyond Go/Node are not installed by this script
- After running: `chsh -s $(which zsh)` if zsh is not already the default shell; launch tmux and press `prefix + I` to install plugins

## Zsh

Main file: `zsh/zshrc` (platform-agnostic)
Platform file: `zsh/platform.zsh` (symlink → `linux.zsh` or `macos.zsh`)

Behavior:

- Loads NVM from `~/.nvm`
- Uses Oh My Zsh from `~/.oh-my-zsh`
- Theme: `robbyrussell`
- Plugin set: `git`
- Sources `~/.config/bw_session`
- Adds Composer vendor bin and `dotfiles/tmux/scripts` to `PATH`
- Sources `zsh/platform.zsh` at the end (resolved via `realpath ~/.zshrc`)

Platform files add:
- Linux: `GOROOT=/usr/local/go`, `GOPATH`, Go/Python `.local/lib`/`.local/bin`, Fly.io
- macOS: Homebrew (`/opt/homebrew/bin`), `GOPATH`, Fly.io

`local.zsh` (gitignored) is sourced last — use it for SSH aliases, tokens, work-specific config.

Aliases of note (in `zshrc`):

- `vi="nvim"`
- `tmux="tmux -2"`
- `art="php artisan"`
- `phpunit="vendor/bin/phpunit"`
- `kitty="~/.local/kitty.app/bin/kitty --start-as=fullscreen"`
- `gpp`: push to several named remotes

Known quirks:

- The shell config depends on `~/.config/bw_session` (sourced unconditionally; silent failure on missing)
- SSH aliases with real hostnames live in `local.zsh`, not tracked in the repo

## Tmux

Main file: `tmux/tmux.conf`

Behavior:

- Default shell: `/bin/zsh`
- Prefix remapped from `Ctrl-b` to `Ctrl-a`
- Window and pane indexes start at `1`
- Mouse support enabled
- Vi-style copy mode enabled
- History limit: `20000`
- Renumbers windows automatically
- Aggressive resize enabled
- Dynamically resolves the tmux config directory and sources `tmux/base16.sh`

Clipboard setup:

- `set -s set-clipboard off` disables tmux terminal clipboard passthrough
- Copy and paste are routed through repo-local helper scripts
- Helpers prefer `wl-copy`/`wl-paste`, then `xclip`, `xsel`, then `pbcopy`/`pbpaste`
- Helpers intentionally avoid Kitty clipboard transport while running inside tmux

Status bar:

- `base16.sh` uses `if-shell "uname | grep -q Darwin"` to choose the right `status-right`
- Linux: `now-playing`, date, CPU/RAM, hostname
- macOS: battery (`pmset`), date, hostname

TPM plugins:

- `tmux-plugins/tpm`
- `tmux-plugins/tmux-resurrect`
- `pwittchen/tmux-plugin-spotify`
- `tmux-plugins/tmux-cpu`

## Kitty

Main file: `kitty/kitty.conf` (platform-agnostic)
Platform file: `kitty/platform.conf` (symlink → `linux.conf` or `macos.conf`)

Behavior (common):

- `adjust_line_height 200%`
- Block cursor with no blink
- Audio bell disabled
- Window padding width `5`
- Clipboard integration enabled
- Active theme include: `kitty/current-theme.conf`

Linux platform (`kitty/linux.conf`):

- JetBrainsMono NF font family, size `13`
- `linux_display_server wayland`
- Fullscreen startup, hidden window decorations

macOS platform (`kitty/macos.conf`):

- JetBrainsMono Nerd Font Mono family, size `16`

## Neovim

Entrypoint:

- `nvim/init.lua`

Active startup modules:

- `shituser.options`
- `shituser.keymap`
- `shituser.autocmd`
- `shituser.lazy`

Core behavior:

- Default indentation: 4 spaces
- Relative line numbers
- Mouse enabled
- Spellcheck enabled for `en_us,bg`
- Case-insensitive search with smartcase
- No wrapping
- Persistent undo enabled
- Backups enabled
- Signcolumn fixed to `yes:2`
- GUI colors enabled
- Clipboard is enabled only when a concrete system clipboard backend is available

Autocommands:

- Highlight TODO/FIXME/NOTE-style comments
- Trim trailing whitespace on save
- Use 2-space indentation for web/Lua-related filetypes
- Run synchronous LSP formatting on save and restore cursor position

Plugin management:

- Active manager: `lazy.nvim`
- Main theme: Catppuccin Macchiato
- LSP stack uses Mason, mason-lspconfig, mason-tool-installer, and `none-ls`
- Main language focus appears to be PHP, Vue, TypeScript, Tailwind, Blade, Lua, and Elixir

## Current Risks

- `install.sh` config symlinking step is intentionally destructive (no backup)
- `zsh/zshrc` unconditionally sources `~/.config/bw_session` (fails silently if missing on a new machine)
- `nvim/lua/shituser/autocmd.lua` formats on every save synchronously, which can block or fail on buffers without a suitable formatter
- `kitty/platform.conf` and `zsh/platform.zsh` are gitignored symlinks — they must exist before kitty/zsh will work; `install.sh` creates them

## Notes for Claude Code

This file (`CLAUDE.md`) is automatically loaded by Claude Code at the start of every session. Keep it current when making structural changes to the repo.

## Current Working Tree Notes

The repo already had local in-progress edits in these active files during this review:

- `kitty/kitty.conf`
- `nvim/lua/shituser/options.lua`
- `tmux/base16.sh`
- `tmux/scripts/clipboard-copy`
- `tmux/scripts/clipboard-paste`
- `tmux/tmux.conf`
- `zsh/zshrc`
