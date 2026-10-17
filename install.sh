#!/usr/bin/env bash
set -e

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

# 2. Automatically detect package manager and install missing packages
if [ ${#MISSING_PKGS[@]} -gt 0 ]; then
    echo "==> Installing missing packages: ${MISSING_PKGS[*]}..."
    
    if command -v rpm-ostree &> /dev/null; then
        # Fedora Silverblue / Kinoite (immutable desktop)
        sudo rpm-ostree install -y "${MISSING_PKGS[@]}"
        echo "==> Packages layered successfully. Note: rpm-ostree changes require a system reboot."
    elif command -v apt-get &> /dev/null; then
        # Debian / Ubuntu Servers
        # Map neovim package name to apt's 'neovim' and stow to 'stow'
        sudo apt-get update && sudo apt-get install -y "${MISSING_PKGS[@]}"
    elif command -v dnf &> /dev/null; then
        # Fedora Server / RHEL / AlmaLinux
        sudo dnf install -y "${MISSING_PKGS[@]}"
    else
        echo "Error: Unsupported package manager. Please install ${MISSING_PKGS[*]} manually." >&2
        exit 1
    fi
fi

# 3. Deploy configurations using GNU Stow
echo "==> Linking configurations with Stow..."
cd "$(dirname "$0")"
stow -R -t ~ nvim tmux

# 4. Initialize Tmux Plugin Manager (TPM) if missing
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "==> Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi

echo "==> Dotfiles installation completed successfully!"
