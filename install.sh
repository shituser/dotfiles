#!/usr/bin/env bash

DOTFILES=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

rm -rf $HOME/.zshrc
ln -s $DOTFILES/zsh/zshrc $HOME/.zshrc

rm -rf $HOME/.config/kitty
ln -s $DOTFILES/kitty $HOME/.config/kitty

rm -rf $HOME/.tmux.conf
#rm -rf $HOME/.tmux/plugins/tpm
#git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
ln -s $DOTFILES/tmux/tmux.conf $HOME/.tmux.conf
