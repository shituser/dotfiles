export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
export PATH=$PATH:$HOME/.local/lib/python3.10/site-packages
export PATH=$PATH:$HOME/.local/bin

# Neovim official stable release (installed to /opt/nvim by install.sh)
export PATH=/opt/nvim/bin:$PATH

export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"
