#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

detect_os() {
  case "$(uname)" in
    Darwin) echo "darwin" ;;
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
    ripgrep fd-find unzip zip \
    playerctl wl-clipboard xclip \
    php-cli composer \
    build-essential autoconf automake gawk gpg dirmngr m4 \
    libncurses-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev \
    unixodbc-dev xsltproc fop libxml2-utils openjdk-17-jdk \
    libssl-dev zlib1g-dev libyaml-dev libxslt1-dev libffi-dev \
    libgdbm-dev libgdbm-compat-dev libreadline-dev libsqlite3-dev \
    libbz2-dev liblzma-dev libcurl4-openssl-dev libjpeg-dev libonig-dev \
    libzip-dev pkg-config bison re2c libpq-dev

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
  brew install tmux neovim zsh git ripgrep fd go

  if ! have kitty; then
    step "Installing Kitty"
    brew install --cask kitty
  fi

  step "Installing JetBrainsMono Nerd Font"
  brew install --cask font-jetbrains-mono-nerd-font

  if ! have composer; then
    step "Installing Composer"
    curl -sS https://getcomposer.org/installer \
      | php -- --install-dir=/usr/local/bin --filename=composer
  fi
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

if [[ "$OS" == "linux" ]]; then
  install_packages_linux
else
  install_packages_darwin
fi

install_asdf
install_tree_sitter
install_oh_my_zsh
link_platform
link_configs
install_tpm

step "Done. Open a new shell to pick up the changes."
echo "  - Run 'chsh -s \$(which zsh)' if zsh is not your default shell."
echo "  - Install runtimes with asdf, e.g. 'asdf plugin add erlang ...' and 'asdf plugin add elixir ...'."
echo "  - Launch tmux and press prefix + I to install plugins."
