#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Painted-J/dotfiles.git"
INSTALL_DIR="$HOME/dotfiles"

# 1. Ensure git is installed (handling root vs non-root)
if ! command -v git &> /dev/null; then
    echo "==> Installing git..."
    SUDO=""
    if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
        SUDO="sudo"
    fi
    
    if command -v apt-get &> /dev/null; then
        $SUDO apt-get update && $SUDO apt-get install -y git
    elif command -v dnf &> /dev/null; then
        $SUDO dnf install -y git
    fi
fi

# 2. Clone repository if not already running from inside it
if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "==> Cloning dotfiles repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    exec "$INSTALL_DIR/install.sh"
fi

echo "==> Starting dotfiles installation..."

# 3. Detect missing packages
MISSING_PKGS=()
for pkg in stow git tmux neovim; do
    cmd="$pkg"
    [ "$pkg" = "neovim" ] && cmd="nvim"
    
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

# 4. Automatically install missing packages
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "==> Installing missing packages: ${MISSING_PKGS[*]}..."
    SUDO=""
    if [ "$EUID" -ne 0 ] && command -v sudo &> /dev/null; then
        SUDO="sudo"
    fi

    if command -v rpm-ostree &> /dev/null; then
        $SUDO rpm-ostree install -y "${MISSING_PKGS[@]}"
    elif command -v apt-get &> /dev/null; then
        $SUDO apt-get update && $SUDO apt-get install -y "${MISSING_PKGS[@]}"
    elif command -v dnf &> /dev/null; then
        $SUDO dnf install -y "${MISSING_PKGS[@]}"
    else
        echo "Error: Unsupported package manager." >&2
        exit 1
    fi
fi

# 5. Deploy configurations using GNU Stow
echo "==> Linking configurations with Stow..."
cd "$INSTALL_DIR"
stow -R -t ~ nvim tmux

# 6. Initialize Tmux Plugin Manager (TPM) if missing
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "==> Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "==> Dotfiles installation completed successfully!"
