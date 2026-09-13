#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# TODO: Laravel dev services — not yet handled by this script (install manually
# for now). When implementing, add a function per service and call it from the
# run sequence at the bottom; gate package names by $OS.
#
#   [ ] MySQL server   — macOS: `brew install mysql` (+ `brew services start mysql`)
#                        Linux: `apt-get install -y mysql-server` (or mariadb-server)
#   [ ] nginx          — macOS: `brew install nginx`
#                        Linux: `apt-get install -y nginx`
#   [ ] Redis          — macOS: `brew install redis` (+ `brew services start redis`)
#                        Linux: `apt-get install -y redis-server`
#   [ ] Memcached      — macOS: `brew install memcached` (+ `brew services start memcached`)
#                        Linux: `apt-get install -y memcached`
#
# Notes:
#   - PHP already builds with pdo_mysql/mysqli (mysqlnd), so no client lib needed.
#   - For Redis/Memcached PHP extensions, install via pecl once PEAR is bundled
#     (pecl install redis / pecl install memcached).
#   - Decide MySQL vs MariaDB before wiring this up; they differ in package names
#     and service handling.
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

detect_os() {
  case "$(uname)" in
    Darwin) echo "macos" ;;
    Linux)  echo "linux"  ;;
    *)      echo "unsupported" ;;
  esac
}

have() { command -v "$1" >/dev/null 2>&1; }

step() { echo; echo "==> $*"; }

OS="$(detect_os)"

if [[ "$OS" == "unsupported" ]]; then
  echo "Unsupported OS: $(uname)" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Package installation
# ---------------------------------------------------------------------------

install_packages_linux() {
  step "Installing packages (apt)"
  sudo apt-get update -q
  sudo apt-get install -y \
    zsh tmux git curl wget \
    ripgrep fd-find unzip zip jq direnv \
    playerctl wl-clipboard xclip \
    build-essential autoconf automake gawk gpg dirmngr m4 \
    libncurses-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev \
    unixodbc-dev xsltproc fop libxml2-utils openjdk-17-jdk \
    libssl-dev zlib1g-dev libyaml-dev libxslt1-dev libffi-dev \
    libgdbm-dev libgdbm-compat-dev libreadline-dev libsqlite3-dev \
    libbz2-dev liblzma-dev libcurl4-openssl-dev libjpeg-dev libonig-dev \
    libzip-dev pkg-config bison re2c libpq-dev inotify-tools

  # Some Erlang GUI/doc packages vary by Ubuntu release, so install them only
  # when the package names exist on the current machine.
  local optional_pkg
  for optional_pkg in libwxgtk3.2-dev libwxgtk-webview3.2-dev; do
    if apt-cache show "$optional_pkg" >/dev/null 2>&1; then
      sudo apt-get install -y "$optional_pkg"
    fi
  done

  # Neovim — use the unstable PPA for a recent release
  if ! have nvim; then
    step "Installing Neovim (PPA)"
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    sudo apt-get update -q
    sudo apt-get install -y neovim
  fi

  # Kitty — official installer
  if ! have kitty; then
    step "Installing Kitty"
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    mkdir -p ~/.local/bin
    ln -sf ~/.local/kitty.app/bin/kitty ~/.local/bin/kitty
    ln -sf ~/.local/kitty.app/bin/kitten ~/.local/bin/kitten
  fi

  # Nerd Fonts — JetBrainsMono
  if ! fc-list | grep -qi "JetBrainsMono NF"; then
    step "Installing JetBrainsMono Nerd Font"
    local tmp; tmp="$(mktemp -d)"
    local version="v3.2.1"
    curl -L "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/JetBrainsMono.zip" \
      -o "$tmp/JetBrainsMono.zip"
    mkdir -p ~/.local/share/fonts
    unzip -q "$tmp/JetBrainsMono.zip" -d ~/.local/share/fonts/JetBrainsMono
    fc-cache -f
    rm -rf "$tmp"
  fi

  # Go — only if not already present
  if ! have go; then
    step "Installing Go"
    local go_version="1.22.3"
    curl -L "https://go.dev/dl/go${go_version}.linux-amd64.tar.gz" | sudo tar -C /usr/local -xz
  fi
}

install_packages_darwin() {
  # Homebrew
  if ! have brew; then
    step "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for the rest of this script
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  fi

  step "Installing packages (Homebrew)"
  brew install tmux neovim zsh git ripgrep fd go jq direnv

  if ! have kitty; then
    step "Installing Kitty"
    brew install --cask kitty
  fi

  step "Installing JetBrainsMono Nerd Font"
  brew install --cask font-jetbrains-mono-nerd-font

  # PHP itself is installed via asdf (see install_php), not Homebrew, so that
  # dev versions are managed consistently and Composer comes bundled. These are
  # the libraries asdf's source build needs at compile AND run time — they are
  # marked on-request here so a later `brew autoremove` won't delete the dylibs
  # the asdf-compiled PHP links against.
  step "Installing PHP build/runtime dependencies"
  brew install autoconf automake bison freetype gd gettext icu4c krb5 \
    libedit libiconv libjpeg libpng libxml2 libzip openssl@3 pkg-config \
    re2c zlib libpq gmp oniguruma libsodium

  # Erlang/Elixir (asdf) build + runtime deps. openssl@3 and autoconf are
  # already installed above. fop + libxslt build the docs; unixodbc enables the
  # odbc app; fswatch powers Phoenix live reload. wxwidgets is for :observer —
  # but note the Homebrew build lacks the --enable-compat30 ABI Erlang's wx
  # needs, so the GUI observer is unusable; use observer_cli / LiveDashboard.
  step "Installing Erlang/Elixir/Phoenix dependencies"
  brew install wxwidgets fop libxslt unixodbc fswatch
}

# ---------------------------------------------------------------------------
# asdf
# ---------------------------------------------------------------------------

install_asdf() {
  mkdir -p "$HOME/.local/bin" "$HOME/.asdf"

  if ! [[ -x "$HOME/.local/bin/asdf" ]]; then
    step "Installing asdf"
    local tmp; tmp="$(mktemp -d)"
    local version="v0.18.1"
    local arch

    case "$(uname -m)" in
      x86_64) arch="amd64" ;;
      aarch64|arm64) arch="arm64" ;;
      *)
        echo "Unsupported architecture for asdf binary install: $(uname -m)" >&2
        exit 1
        ;;
    esac

    curl -fL "https://github.com/asdf-vm/asdf/releases/download/${version}/asdf-${version}-${OS}-${arch}.tar.gz" \
      -o "$tmp/asdf.tar.gz"
    tar -xzf "$tmp/asdf.tar.gz" -C "$tmp"
    install -m 0755 "$tmp/asdf" "$HOME/.local/bin/asdf"
    rm -rf "$tmp"
  else
    echo "asdf already present, skipping"
  fi
}

# ---------------------------------------------------------------------------
# tree-sitter-cli (required by nvim-treesitter main branch to compile parsers)
# ---------------------------------------------------------------------------

install_tree_sitter() {
  local asdf_bin="$HOME/.local/bin/asdf"
  if "$asdf_bin" list tree-sitter 2>/dev/null | grep -q '[0-9]'; then
    echo "tree-sitter already installed via asdf, skipping"
    return
  fi
  step "Installing tree-sitter-cli (via asdf)"
  "$asdf_bin" plugin add tree-sitter https://github.com/ivanvc/asdf-tree-sitter.git 2>/dev/null || true
  "$asdf_bin" install tree-sitter latest
  "$asdf_bin" set -u tree-sitter latest
}

# ---------------------------------------------------------------------------
# Node.js (required by Mason for npm-based LSPs: tailwindcss, vtsls, vue, etc.)
# ---------------------------------------------------------------------------

install_nodejs() {
  local asdf_bin="$HOME/.local/bin/asdf"
  if "$asdf_bin" list nodejs 2>/dev/null | grep -q '[0-9]'; then
    echo "nodejs already installed via asdf, skipping"
    return
  fi
  step "Installing Node.js LTS (via asdf)"
  "$asdf_bin" plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git 2>/dev/null || true
  "$asdf_bin" install nodejs lts
  "$asdf_bin" set -u nodejs lts
}

# ---------------------------------------------------------------------------
# PHP (via asdf — also bundles Composer, so no separate Composer install)
# ---------------------------------------------------------------------------

install_php() {
  local asdf_bin="$HOME/.local/bin/asdf"
  local php_version="8.3.31"
  if "$asdf_bin" list php 2>/dev/null | grep -q "$php_version"; then
    echo "php $php_version already installed via asdf, skipping"
    return
  fi
  step "Installing PHP $php_version (via asdf — bundles Composer)"
  "$asdf_bin" plugin add php https://github.com/asdf-community/asdf-php.git 2>/dev/null || true

  # The asdf-php plugin hard-codes openssl@1.1, which is EOL and uninstallable
  # on current Homebrew. Without OpenSSL, PHP builds with no `https` stream
  # wrapper, which breaks both the PEAR step and the plugin's bundled-Composer
  # download. Point the plugin at openssl@3 (fully supported by PHP 8.3).
  if [[ "$OS" == "macos" ]]; then
    sed -i '' 's/openssl@1\.1/openssl@3/g' "$HOME/.asdf/plugins/php/bin/install"
    # Homebrew bison/libxml2 are keg-only but required to build PHP's parser.
    export PATH="/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/libxml2/bin:$PATH"
  fi

  # PEAR is left enabled (the plugin default) so that `pecl` is bundled — needed
  # to install PHP extensions like redis/memcached/xdebug for Laravel. PEAR's
  # installer fetches itself over https at build time, which is why the OpenSSL
  # fix above is a hard prerequisite: without it this step fails.

  "$asdf_bin" install php "$php_version"
  "$asdf_bin" set -u php "$php_version"
}

# ---------------------------------------------------------------------------
# Erlang/OTP (via asdf — built from source by kerl)
# ---------------------------------------------------------------------------

install_erlang() {
  local asdf_bin="$HOME/.local/bin/asdf"
  local erlang_version="28.5"
  if "$asdf_bin" list erlang 2>/dev/null | grep -q "$erlang_version"; then
    echo "erlang $erlang_version already installed via asdf, skipping"
    return
  fi
  step "Installing Erlang/OTP $erlang_version (via asdf — compiles from source)"
  "$asdf_bin" plugin add erlang https://github.com/asdf-vm/asdf-erlang.git 2>/dev/null || true

  # macOS only: build crypto/ssl against Homebrew openssl@3 — the system
  # LibreSSL headers won't produce a working crypto app (same rationale as the
  # PHP build). Skip the Java jinterface bridge (--without-javac). On Linux the
  # apt libssl-dev is found automatically, so no override is needed there.
  if [[ "$OS" == "macos" ]]; then
    export KERL_CONFIGURE_OPTIONS="--without-javac --with-ssl=$(brew --prefix openssl@3)"
  fi

  "$asdf_bin" install erlang "$erlang_version"
  "$asdf_bin" set -u erlang "$erlang_version"
}

# ---------------------------------------------------------------------------
# Elixir (via asdf — precompiled; version must match Erlang's OTP major)
# ---------------------------------------------------------------------------

install_elixir() {
  local asdf_bin="$HOME/.local/bin/asdf"
  # The -otp-NN suffix MUST match the OTP major installed in install_erlang.
  local elixir_version="1.19.5-otp-28"
  if "$asdf_bin" list elixir 2>/dev/null | grep -q "$elixir_version"; then
    echo "elixir $elixir_version already installed via asdf, skipping"
    return
  fi
  step "Installing Elixir $elixir_version (via asdf — precompiled)"
  "$asdf_bin" plugin add elixir https://github.com/asdf-vm/asdf-elixir.git 2>/dev/null || true
  "$asdf_bin" install elixir "$elixir_version"
  "$asdf_bin" set -u elixir "$elixir_version"
}

# ---------------------------------------------------------------------------
# Phoenix (Hex + rebar + the phx_new project generator)
# ---------------------------------------------------------------------------

install_phoenix() {
  local asdf_bin="$HOME/.local/bin/asdf"
  "$asdf_bin" reshim elixir
  local mix="$HOME/.asdf/shims/mix"
  if "$mix" archive 2>/dev/null | grep -q 'phx_new'; then
    echo "Phoenix generator already installed, skipping"
    return
  fi
  step "Installing Hex, rebar, and the Phoenix generator"
  "$mix" local.hex --force
  "$mix" local.rebar --force
  "$mix" archive.install hex phx_new --force
}

# ---------------------------------------------------------------------------
# Oh My Zsh
# ---------------------------------------------------------------------------

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    step "Installing Oh My Zsh"
    RUNZSH=no CHSH=no \
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "oh-my-zsh already present, skipping"
  fi
}

# ---------------------------------------------------------------------------
# Platform symlinks
# ---------------------------------------------------------------------------

link_platform() {
  step "Linking platform config files ($OS)"
  ln -sf "$DOTFILES/kitty/${OS}.conf" "$DOTFILES/kitty/platform.conf"
  ln -sf "$DOTFILES/zsh/${OS}.zsh"    "$DOTFILES/zsh/platform.zsh"
}

# ---------------------------------------------------------------------------
# Config symlinks
# ---------------------------------------------------------------------------

link_configs() {
  step "Linking config files"

  rm -f "$HOME/.asdfrc"
  ln -s "$DOTFILES/.asdfrc" "$HOME/.asdfrc"

  rm -f "$HOME/.zshrc"
  ln -s "$DOTFILES/zsh/zshrc" "$HOME/.zshrc"

  rm -rf "$HOME/.config/kitty"
  ln -s "$DOTFILES/kitty" "$HOME/.config/kitty"

  rm -f "$HOME/.tmux.conf"
  ln -s "$DOTFILES/tmux/tmux.conf" "$HOME/.tmux.conf"

  rm -rf "$HOME/.config/nvim"
  ln -s "$DOTFILES/nvim" "$HOME/.config/nvim"
}

# ---------------------------------------------------------------------------
# TPM
# ---------------------------------------------------------------------------

install_tpm() {
  step "Installing TPM"
  rm -rf "$HOME/.tmux/plugins/tpm"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

step "Detected OS: $OS"
step "Dotfiles directory: $DOTFILES"

if [[ "$OS" == "linux" ]]; then
  install_packages_linux
else
  install_packages_darwin
fi

install_asdf
install_tree_sitter
install_nodejs
install_php
install_erlang
install_elixir
install_phoenix
install_oh_my_zsh
link_platform
link_configs
install_tpm

step "Done. Open a new shell to pick up the changes."
echo "  - Run 'chsh -s \$(which zsh)' if zsh is not your default shell."
echo "  - Scaffold a Phoenix app with 'mix phx.new <name>'."
echo "  - Launch tmux and press prefix + I to install plugins."
