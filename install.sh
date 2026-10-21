#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Painted-J/dotfiles.git"
INSTALL_DIR="$HOME/dotfiles"

# 1. Clone the repository if it doesn't exist yet
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "==> Cloning dotfiles repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# 2. Stow configurations
echo "==> Linking configurations with Stow..."
cd "$INSTALL_DIR"
stow -R -t ~ nvim tmux

echo "==> Stow deployment completed successfully!"
