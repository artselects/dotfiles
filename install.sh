#!/usr/bin/env bash
set -euo pipefail

# ── Dotfiles Installer ──────────────────────────────────────────
# Works on: Ubuntu/Debian, Amazon Linux/RHEL/Fedora, macOS
# Usage: git clone <repo> ~/dotfiles && cd ~/dotfiles && ./install.sh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}${BOLD}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}${BOLD}[OK]${NC} $1"; }
err()   { echo -e "${RED}${BOLD}[ERR]${NC} $1"; }

# ── Detect OS ──
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|pop|linuxmint) echo "debian" ;;
            amzn|rhel|centos|fedora|rocky|alma) echo "rhel" ;;
            *) echo "unknown" ;;
        esac
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
info "Detected OS family: $OS"

# ── Package install helper ──
pkg_install() {
    local packages=("$@")
    case "$OS" in
        macos)
            if ! command -v brew &>/dev/null; then
                info "Installing Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            brew install "${packages[@]}"
            ;;
        debian)
            sudo apt-get update -qq
            sudo apt-get install -y -qq "${packages[@]}"
            ;;
        rhel)
            if command -v dnf &>/dev/null; then
                sudo dnf install -y "${packages[@]}"
            else
                sudo yum install -y "${packages[@]}"
            fi
            ;;
        *)
            err "Unsupported OS. Install manually: ${packages[*]}"
            exit 1
            ;;
    esac
}

# ── Install core packages ──
info "Installing core packages..."
case "$OS" in
    macos) pkg_install zsh tmux curl git fzf bat eza fd zoxide ;;
    debian) pkg_install zsh tmux curl git unzip fontconfig fzf bat eza fd-find zoxide ;;
    rhel) pkg_install zsh tmux curl git unzip fontconfig fzf ;;
esac
ok "Core packages installed"

# ── Install Ghostty ──
if ! command -v ghostty &>/dev/null; then
    info "Installing Ghostty..."
    case "$OS" in
        macos)
            brew install --cask ghostty
            ;;
        debian)
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)" > /dev/null 2>&1
            ;;
        *)
            info "Ghostty: no auto-install for $OS — see https://ghostty.org/download"
            ;;
    esac
    if command -v ghostty &>/dev/null; then
        ok "Ghostty installed"
    fi
else
    ok "Ghostty already installed"
fi

# ── Install JetBrainsMono Nerd Font ──
install_nerd_font() {
    local font_name="JetBrainsMono"
    local font_version="v3.3.0"
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${font_version}/${font_name}.zip"

    if [[ "$OS" == "macos" ]]; then
        local font_dir="$HOME/Library/Fonts"
    else
        local font_dir="$HOME/.local/share/fonts"
    fi

    # Check if already installed
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd" || \
       ls "$font_dir"/*JetBrainsMono* &>/dev/null 2>&1; then
        ok "JetBrainsMono Nerd Font already installed"
        return
    fi

    info "Installing JetBrainsMono Nerd Font..."
    mkdir -p "$font_dir"
    local tmp_dir
    tmp_dir=$(mktemp -d)
    curl -fsSL "$font_url" -o "$tmp_dir/font.zip"
    unzip -qo "$tmp_dir/font.zip" -d "$tmp_dir/font"
    cp "$tmp_dir"/font/*.ttf "$font_dir/" 2>/dev/null || true
    rm -rf "$tmp_dir"

    # Refresh font cache (Linux only)
    if [[ "$OS" != "macos" ]] && command -v fc-cache &>/dev/null; then
        fc-cache -f "$font_dir"
    fi
    ok "JetBrainsMono Nerd Font installed"
}
install_nerd_font

# ── Install Oh My Zsh ──
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    info "Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" > /dev/null 2>&1
    ok "Oh My Zsh installed"
else
    ok "Oh My Zsh already installed"
fi

# ── Install Powerlevel10k ──
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
    info "Installing Powerlevel10k..."
    git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
    ok "Powerlevel10k installed"
else
    ok "Powerlevel10k already installed"
fi

# ── Install Oh My Zsh plugins ──
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_omz_plugin() {
    local name="$1" repo="$2"
    local dest="$ZSH_CUSTOM/plugins/$name"
    if [[ -d "$dest" ]]; then
        ok "$name already installed"
    else
        info "Installing $name..."
        git clone -q "$repo" "$dest"
        ok "$name installed"
    fi
}

install_omz_plugin "zsh-autosuggestions"     "https://github.com/zsh-users/zsh-autosuggestions.git"
install_omz_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_omz_plugin "zsh-completions"         "https://github.com/zsh-users/zsh-completions.git"

# ── Install CLI tools not available via package manager ──
# eza (on older distros or RHEL that don't have it)
if ! command -v eza &>/dev/null; then
    info "Installing eza..."
    EZA_VERSION=$(curl -sS https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f 4)
    if [[ -n "$EZA_VERSION" ]]; then
        curl -fsSL "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eza /usr/local/bin/ 2>/dev/null && ok "eza installed" || info "Could not install eza (no sudo)"
    fi
fi

# bat alias for Debian (packaged as batcat)
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(command -v batcat)" ~/.local/bin/bat
    ok "Created bat -> batcat symlink"
fi

# fd alias for Debian (packaged as fdfind)
if command -v fdfind &>/dev/null && ! command -v fd &>/dev/null; then
    mkdir -p ~/.local/bin
    ln -sf "$(command -v fdfind)" ~/.local/bin/fd
    ok "Created fd -> fdfind symlink"
fi

# ── Symlink configs ──
info "Symlinking config files..."

symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" && ! -L "$dst" ]]; then
        mv "$dst" "${dst}.backup.$(date +%s)"
        info "Backed up existing $dst"
    fi
    ln -sf "$src" "$dst"
}

symlink "$DOTFILES_DIR/zsh/.zshrc"                "$HOME/.zshrc"
symlink "$DOTFILES_DIR/tmux/tmux.conf"             "$HOME/.tmux.conf"
symlink "$DOTFILES_DIR/alacritty/alacritty.toml"   "$HOME/.config/alacritty/alacritty.toml"
symlink "$DOTFILES_DIR/ghostty/config"             "$HOME/.config/ghostty/config"

# Symlink p10k config if it exists in dotfiles
if [[ -f "$DOTFILES_DIR/zsh/.p10k.zsh" ]]; then
    symlink "$DOTFILES_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
fi

ok "Configs symlinked"

# ── Set default shell to zsh ──
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    info "Setting default shell to zsh..."
    if sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null; then
        ok "Default shell set to zsh"
    else
        info "Automatic chsh failed. Please run manually: chsh -s $ZSH_PATH"
        info "For now, you can start zsh with: exec zsh"
    fi
else
    ok "Shell is already zsh"
fi

# ── Done ──
echo ""
echo -e "${GREEN}${BOLD}Setup complete!${NC}"
echo ""
echo "  Next steps:"
echo "  1. Open a new terminal (or run: exec zsh)"
echo "  2. Powerlevel10k config wizard will run on first launch"
echo "     (run 'p10k configure' anytime to reconfigure)"
echo "  3. Set your terminal font to 'JetBrainsMono Nerd Font'"
echo "  4. For local overrides, create ~/.zshrc.local"
echo ""
