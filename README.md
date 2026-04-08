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
2. Installs packages: zsh, tmux, Neovim, Kitty, Go, ripgrep, fd, playerctl, wl-clipboard, Composer, JetBrainsMono Nerd Font
3. Installs NVM and Oh My Zsh (skipped if already present)
4. Creates platform symlinks (`kitty/platform.conf`, `zsh/platform.zsh`)
5. Symlinks configs into `$HOME`
6. Clones TPM (tmux plugin manager)

After install, Mason (inside Neovim) handles LSP server installation on first launch. Node (via NVM) and Go must be present first — the script installs both.

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
  linux.zsh / macos.zsh  platform PATH exports
  local.zsh.example      template for private overrides
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
