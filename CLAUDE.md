# Dotfiles Context

Last reviewed: 2026-04-16
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
- `.asdfrc`: asdf config (currently enables legacy version-file support for `.nvmrc`)
- `zsh/zshrc`: main shell config (platform-agnostic)
- `zsh/asdf.zsh`: asdf shell init loaded by `zshrc`
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
- `tmux/scripts/claude-usage`: Claude Code usage stats for tmux status bar (session %, session reset time, weekly %, Fable weekly %)
- `tmux/scripts/status-centre`: injects a centred section (from the `@status-centre` option) into the default tmux status line
- `kitty/kitty.conf`: terminal config (platform-agnostic; includes `platform.conf`)
- `kitty/linux.conf`: Linux font settings (NF font names, size 13)
- `kitty/macos.conf`: macOS font settings (Nerd Font Mono, size 15)
- `kitty/platform.conf`: symlink created by `install.sh` → points to `linux.conf` or `macos.conf`
- `kitty/current-theme.conf`: active Kitty theme include
- `kitty/Ayu Mirage.conf`: alternate Kitty theme file kept in repo
- `bin/kitty`: Linux wrapper that abstracts fullscreen startup differences across desktop environments
- `nvim/init.lua`: Neovim entrypoint
- `nvim/lua/shituser/*`: active Neovim Lua config
- `nvim/after/lsp/vtsls.lua`: per-server Vue/TypeScript override
- `nvim/lazy-lock.json`: Lazy plugin lockfile
- `macos/BulgarianPhoneticBDS.keylayout`: macOS-only Bulgarian phonetic (BDS) keyboard layout (installed manually, not by `install.sh`)
- `composer/.htaccess`: unrelated leftover; not part of the active terminal/editor setup

## Bootstrap / Install Behavior

`install.sh` is a full bootstrap script. It detects the OS (`uname`) and:

1. **Installs packages** (OS-dispatched):
   - Linux (apt/Ubuntu): zsh, tmux, git, curl, ripgrep, fd-find, playerctl, wl-clipboard, xclip, jq, direnv, inotify-tools, and build deps for asdf-managed Erlang/Elixir/Node/PHP; Neovim from the official stable release tarball into `/opt/nvim` (`/opt/nvim/bin` added to `PATH` in `zsh/linux.zsh`); Kitty from official installer; JetBrainsMono Nerd Font from nerd-fonts releases; Go from golang.org
   - macOS (Homebrew): tmux, neovim, zsh, git, ripgrep, fd, go; Kitty and JetBrainsMono Nerd Font via cask; Composer via curl installer
2. Installs asdf to `~/.asdf` (idempotent — skips if present)
3. Installs Oh My Zsh (idempotent — skips if `~/.oh-my-zsh` exists)
4. Creates platform symlinks: `kitty/platform.conf` → `kitty/{os}.conf`, `zsh/platform.zsh` → `zsh/{os}.zsh`
5. Symlinks configs into `$HOME` (destructive: uses `rm -f`/`rm -rf` on existing targets), including `~/.asdfrc`
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

- Loads asdf from `~/.asdf` via `zsh/asdf.zsh`
- Uses Oh My Zsh from `~/.oh-my-zsh`
- Theme: `robbyrussell`
- Plugin set: `git`
- `~/.config/bw_session` sourcing is currently commented out
- Optionally loads Google Cloud SDK and opencode when installed in `$HOME`
- Adds Composer vendor bin and `dotfiles/tmux/scripts` to `PATH` (repo path resolved via `realpath ~/.zshrc`, since the repo lives at `~/Public/dotfiles` on Linux and `~/Sites/dotfiles` on macOS)
- Loads the direnv zsh hook when `direnv` is installed (installed by `install.sh` on both platforms)
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
- `gpp`: push to several named remotes

Known quirks:

- `~/.asdfrc` is symlinked from the repo and currently enables `legacy_version_file = yes` for smoother Node migration from `.nvmrc`
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
- Centre (both platforms): `claude-usage`, via `scripts/status-centre`
- Linux right: `now-playing`, date, CPU/RAM, hostname
- macOS right: battery (`pmset`), date, hostname

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
- Hidden window decorations; display server auto-detected
- Fullscreen startup is handled by `bin/kitty` (symlinked to `~/.local/bin/kitty`), which uses `--start-as=fullscreen` or, on GNOME, a post-launch toggle

macOS platform (`kitty/macos.conf`):

- JetBrainsMono Nerd Font Mono family, size `15`

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

## macOS Portability Traps

The repo is shared by Linux (`~/Public/dotfiles`) and macOS (`~/Sites/dotfiles`), so anything sourced on both must survive BSD userland and macOS's bash 3.2. Traps that have bitten, or nearly bitten, a `git pull` onto the macOS machine:

- **bash 3.2**: macOS still ships bash 3.2, where quoting inside `${var/pat/rep}` cannot be trusted to keep glob characters (`[`) literal. `tmux/scripts/status-centre` therefore inserts with `awk` `index`/`substr`, and passes strings via `ENVIRON` because `awk -v` interprets escape sequences.
- **BSD vs GNU flags**: `stat -c` and `date -d` are GNU-only. `tmux/scripts/claude-usage` keeps them in its non-Darwin branch and uses `stat -f %m`, `date -j -f`, `date -r` on macOS. `install.sh` uses the BSD `sed -i ''` form, and only inside an `$OS == macos` guard.
- **`status-centre` needs tmux 3.2+** for `align=absolute-centre`. On older tmux, or if the marker is missing from tmux's default `status-format[0]`, or if the `set` fails, it prepends the widget to `status-right` instead of silently showing nothing.
- **`claude-usage` reads the macOS keychain** (`security find-generic-password -s "Claude Code-credentials" -w`), which may need a keychain prompt approved once. Run the script directly if the widget is blank.
- **Kitty's font wizard rewrites `kitty/kitty.conf`**, appending a `BEGIN_KITTY_FONTS` block *after* `include platform.conf`, which then overrides the Linux fonts too. Font settings belong in `macos.conf` / `linux.conf`; delete any regenerated block from `kitty.conf`.
- **PATH order**: `platform.zsh` prepends Homebrew, which would shadow asdf-managed runtimes (e.g. `php`), so `zshrc` re-asserts `$ASDF_DATA_DIR/shims` at the front afterwards.
- **asdf-php and OpenSSL**: the plugin hard-codes the EOL `openssl@1.1`, so `install.sh` rewrites it to `openssl@3` on macOS. Without that, PHP builds with no `https` stream wrapper and both the PEAR step and the bundled-Composer download fail.
- **Pulling with uncommitted work**: `git stash push -m wip && git pull --ff-only && git stash pop` — the stash stays recoverable if the pop conflicts. Expect conflicts in whichever files were edited on both machines.

## Current Risks

- `install.sh` config symlinking step is intentionally destructive (no backup)
- `nvim/lua/shituser/autocmd.lua` formats on every save synchronously, which can block or fail on buffers without a suitable formatter
- `systemd/php83-asdf-fpm.service` is an untracked, never-installed draft; the Linux machine actually runs `/etc/systemd/system/php-fpm-asdf.service` (8.3.30) and `php-fpm-asdf74.service`, both with hardcoded paths and versions
- `kitty/platform.conf` and `zsh/platform.zsh` are gitignored symlinks — they must exist before kitty/zsh will work; `install.sh` creates them

## Notes for Claude Code

This file (`CLAUDE.md`) is automatically loaded by Claude Code at the start of every session. Keep it current when making structural changes to the repo.

## Current Working Tree Notes

The working tree is clean as of 2026-09-19, apart from the untracked `systemd/` draft noted under Current Risks.
