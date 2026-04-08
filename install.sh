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
    ripgrep fd-find \
    playerctl wl-clipboard xclip \
    php-cli composer

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
# NVM
# ---------------------------------------------------------------------------

install_nvm() {
  if [[ ! -d "$HOME/.nvm" ]]; then
    step "Installing NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  else
    echo "nvm already present, skipping"
  fi
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

install_nvm
install_oh_my_zsh
link_platform
link_configs
install_tpm

step "Done. Open a new shell to pick up the changes."
echo "  - Run 'chsh -s \$(which zsh)' if zsh is not your default shell."
echo "  - Launch tmux and press prefix + I to install plugins."
