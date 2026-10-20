#!/usr/bin/env bash
set -e

INSTALL_DIR="$HOME/dotfiles"

echo "==> Linking configurations with Stow..."
cd "$INSTALL_DIR"
stow -R -t ~ nvim tmux

echo "==> Stow deployment completed successfully!"
