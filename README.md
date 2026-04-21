# dotfiles

Personal terminal environment for Linux (Ubuntu/Wayland) and macOS.

**Stack:** Zsh + Oh My Zsh · tmux · Kitty · Neovim

---

## Quick start

```bash
git clone <repo> ~/Public/dotfiles
cd ~/Public/dotfiles
./install.sh
chsh -s $(which zsh)
```

Then launch tmux and press `Ctrl-a + I` to install plugins.

> **Warning:** `install.sh` is destructive — it removes existing config targets before symlinking. Run it on a fresh machine or when your dotfiles are the source of truth.

---

## What `install.sh` does

1. Detects OS (`uname`) — supports Linux (apt/Ubuntu) and macOS (Homebrew)
2. Installs packages: zsh, tmux, Neovim, Kitty, Go, ripgrep, fd, playerctl, wl-clipboard, Composer, JetBrainsMono Nerd Font, and asdf build dependencies for Erlang/Elixir/Node/PHP
3. Installs asdf and Oh My Zsh (skipped if already present)
4. Creates platform symlinks (`kitty/platform.conf`, `zsh/platform.zsh`)
5. Symlinks configs into `$HOME` (including `~/.asdfrc`)
6. Clones TPM (tmux plugin manager)

After install, Mason (inside Neovim) handles LSP server installation on first launch. Go is still installed system-wide by the script; Node/Elixir/PHP are intended to be installed via asdf.

---

## asdf runtime management

The shell config now loads `asdf` from `~/.asdf`, and the repo ships an `~/.asdfrc` with:

```ini
legacy_version_file = yes
```

That keeps Node migration smoother because `asdf-nodejs` can read existing `.nvmrc` files.

### Recommended scope

Use asdf for language runtimes and CLI tooling:

- Erlang
- Elixir
- Node.js
- PHP

Use system packages or containers for long-running database services:

- PostgreSQL server
- MySQL server

asdf is fine for versioned client binaries, but database daemons tend to fit better with `apt`, Docker, or dedicated service managers on a workstation.

### Phoenix / Elixir setup

Official references:

- asdf getting started: https://asdf-vm.com/guide/getting-started.html
- asdf-erlang: https://github.com/asdf-vm/asdf-erlang
- asdf-elixir: https://github.com/asdf-vm/asdf-elixir
- Elixir compatibility table: https://hexdocs.pm/elixir/compatibility-and-deprecations.html
- Phoenix installation: https://hexdocs.pm/phoenix/installation.html

Install plugins:

```bash
asdf plugin add erlang https://github.com/asdf-vm/asdf-erlang.git
asdf plugin add elixir https://github.com/asdf-vm/asdf-elixir.git
```

Pick compatible versions, then install and select them globally:

```bash
asdf list-all erlang | tail
asdf list-all elixir | tail

asdf install erlang <otp-version>
asdf install elixir <elixir-version>-otp-<otp-major>

asdf set --home erlang <otp-version>
asdf set --home elixir <elixir-version>-otp-<otp-major>
```

For Elixir `1.18.x`, the official compatibility table says Erlang/OTP `25` through `27` are supported. A practical default is the latest OTP 27 release plus the matching `1.18.x-otp-27` Elixir build.

Then install Phoenix:

```bash
mix local.hex --force
mix local.rebar --force
mix archive.install hex phx_new --force
asdf reshim elixir
```

### Node.js migration from NVM

Install the plugin and your target Node release:

```bash
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs <version>
asdf set --home nodejs <version>
corepack enable
asdf reshim nodejs
```

`asdf-nodejs` officially supports reading `.nvmrc` when `legacy_version_file = yes` is set, which this repo now does via `~/.asdfrc`.

### PHP with asdf

PHP support is community-maintained rather than part of the asdf core org:

- Plugin: https://github.com/asdf-community/asdf-php

Install flow:

```bash
asdf plugin add php https://github.com/asdf-community/asdf-php.git
asdf install php <version>
asdf set --home php <version>
asdf reshim php
```

`asdf-php` installs Composer globally alongside PHP by default.

---

## Cross-platform setup

Configs are split into platform-agnostic main files and OS-specific include files. `install.sh` creates the right symlink for the current machine.

| Tool | Main file | Linux | macOS |
|------|-----------|-------|-------|
| Kitty | `kitty/kitty.conf` | `kitty/linux.conf` | `kitty/macos.conf` |
| Zsh | `zsh/zshrc` | `zsh/linux.zsh` | `zsh/macos.zsh` |
| tmux status bar | `tmux/base16.sh` | now-playing + CPU | battery |

The symlinks (`kitty/platform.conf`, `zsh/platform.zsh`) are gitignored — they exist only on your machine.

---

## Local overrides

Private aliases, SSH shortcuts, and tokens go in `zsh/local.zsh` — gitignored, never committed.

```bash
cp zsh/local.zsh.example zsh/local.zsh
# edit zsh/local.zsh
```

---

## Layout

```
install.sh               bootstrap script
zsh/
  zshrc                  main shell config
  asdf.zsh               asdf shell init
  linux.zsh / macos.zsh  platform PATH exports
  local.zsh.example      template for private overrides
.asdfrc                  asdf defaults (legacy .nvmrc support)
tmux/
  tmux.conf              main config (prefix: Ctrl-a)
  base16.sh              theme + status bar
  scripts/
    clipboard-copy       wl-copy / xclip / xsel / pbcopy
    clipboard-paste      wl-paste / xclip / xsel / pbpaste
    now-playing          playerctl music status (Linux)
kitty/
  kitty.conf             main terminal config
  linux.conf             Linux fonts + Wayland settings
  macos.conf             macOS fonts
  current-theme.conf     active color theme (Catppuccin Macchiato)
nvim/
  init.lua               entrypoint
  lua/shituser/          Lua config modules
  after/lsp/vtsls.lua    Vue/TypeScript LSP override
```

---

## Neovim

- Plugin manager: `lazy.nvim`
- Theme: Catppuccin Macchiato (Tokyonight kept as alternate)
- LSP: Mason + mason-lspconfig + none-ls
- Languages: PHP, Vue, TypeScript, Tailwind, Blade, Lua, Elixir
- Format on save (synchronous, LSP-based)
- Spellcheck: `en_us` + `bg`
- Clipboard: auto-detected at startup (wl-clipboard → xclip → xsel → pbcopy)

---

## tmux

- Prefix: `Ctrl-a`
- Vi copy mode; `y` copies to system clipboard
- Plugins: tmux-resurrect, tmux-cpu, tmux-plugin-spotify
- Clipboard bypasses Kitty's terminal protocol to avoid conflicts inside tmux

---

## Kitty

- Font: JetBrainsMono Nerd Font
- Theme: Catppuccin Macchiato
- Wayland-first on Linux; fullscreen by default
