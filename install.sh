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

# 3. Detect missing base packages (excluding neovim from apt)
MISSING_PKGS=()
for pkg in stow git tmux; do
    if ! command -v "$pkg" &> /dev/null; then
        MISSING_PKGS+=("$pkg")
    fi
done

# 4. Automatically install missing base packages
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

# 5. Install latest Neovim binary if missing or outdated (< v0.9)
if ! command -v nvim &> /dev/null || [[ "$(nvim --version | head -n 1)" =~ "v0.7" || "$(nvim --version | head -n 1)" =~ "v0.8" ]]; then
    echo "==> Installing latest Neovim AppImage..."
    curl -LO https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.appimage
    chmod +x nvim-linux64.appimage
    mv nvim-linux64.appimage /usr/local/bin/nvim
fi

# 6. Deploy configurations using GNU Stow
echo "==> Linking configurations with Stow..."
cd "$INSTALL_DIR"
stow -R -t ~ nvim tmux

# 7. Initialize Tmux Plugin Manager (TPM) if missing
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "==> Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "==> Dotfiles installation completed successfully!"
