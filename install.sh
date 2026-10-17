#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Painted-J/dotfiles.git"
INSTALL_DIR="$HOME/dotfiles"

# If not running from inside the cloned repo, clone it and re-execute
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "==> Cloning dotfiles repository..."
    if ! command -v git &> /dev/null; then
        # Quick fallback to install git just to clone the repo if missing
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y git
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y git
        fi
    fi
    git clone "$REPO_URL" "$INSTALL_DIR"
    exec "$INSTALL_DIR/install.sh"
fi

echo "==> Starting dotfiles installation..."

# 1. Detect missing packages
MISSING_PKGS=()
for pkg in stow git tmux neovim; do
    cmd="$pkg"
    [ "$pkg" = "neovim" ] && cmd="nvim"
    
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

# 2. Automatically install missing packages
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "==> Installing missing packages: ${MISSING_PKGS[*]}..."
    if command -v rpm-ostree &> /dev/null; then
        sudo rpm-ostree install -y "${MISSING_PKGS[@]}"
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y "${MISSING_PKGS[@]}"
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y "${MISSING_PKGS[@]}"
    else
        echo "Error: Unsupported package manager. Please install ${MISSING_PKGS[*]} manually." >&2
        exit 1
    fi
fi

# 3. Deploy configurations using GNU Stow
echo "==> Linking configurations with Stow..."
cd "$INSTALL_DIR"
stow -R -t ~ nvim tmux

# 4. Initialize Tmux Plugin Manager (TPM) if missing
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "==> Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "==> Dotfiles installation completed successfully!"
