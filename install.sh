#!/usr/bin/env bash
set -euo pipefail

# ── Dotfiles Installer ──────────────────────────────────────────
# Works on: Ubuntu/Debian, Amazon Linux/RHEL/Fedora, macOS
# Usage: git clone <repo> ~/dotfiles && cd ~/dotfiles && ./install.sh

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$HOME/.zsh/plugins"

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

# ── Install packages ──
info "Installing core packages..."
case "$OS" in
    macos) pkg_install zsh tmux curl git ;;
    debian) pkg_install zsh tmux curl git unzip fontconfig ;;
    rhel) pkg_install zsh tmux curl git unzip fontconfig ;;
esac
ok "Core packages installed"

# ── Install Starship ──
if ! command -v starship &>/dev/null; then
    info "Installing Starship prompt..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
    ok "Starship installed"
else
    ok "Starship already installed"
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

# ── Install zsh plugins ──
install_zsh_plugin() {
    local name="$1" repo="$2"
    local dest="$PLUGIN_DIR/$name"
    if [[ -d "$dest" ]]; then
        info "Updating $name..."
        git -C "$dest" pull -q
    else
        info "Installing $name..."
        git clone -q "$repo" "$dest"
    fi
}

mkdir -p "$PLUGIN_DIR"
install_zsh_plugin "zsh-autosuggestions"    "https://github.com/zsh-users/zsh-autosuggestions.git"
install_zsh_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting.git"
install_zsh_plugin "zsh-completions"         "https://github.com/zsh-users/zsh-completions.git"
ok "Zsh plugins installed"

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
symlink "$DOTFILES_DIR/starship/starship.toml"     "$HOME/.config/starship.toml"
symlink "$DOTFILES_DIR/tmux/tmux.conf"             "$HOME/.tmux.conf"
symlink "$DOTFILES_DIR/alacritty/alacritty.toml"   "$HOME/.config/alacritty/alacritty.toml"
symlink "$DOTFILES_DIR/ghostty/config"             "$HOME/.config/ghostty/config"

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
echo "  2. Set your terminal font to 'JetBrainsMono Nerd Font'"
echo "  3. For local overrides, create ~/.zshrc.local"
echo ""
