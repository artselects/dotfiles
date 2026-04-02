#!/usr/bin/env bash

# This script remaps keys to mimic macOS layout on Ubuntu 24.04+.
# It installs and configures 'keyd' for system-wide Command keys and shortcuts.

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── 1. Clear any existing GNOME key swaps ──
echo "Clearing GNOME-level key swaps (we will use keyd instead)..."
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.input-sources xkb-options "['']"
fi

# ── 2. Locate keyd binary ──
KEYD_BIN="/usr/bin/keyd.rvaiya"
if [[ ! -x "$KEYD_BIN" ]]; then
    KEYD_BIN=$(command -v keyd || echo "/usr/bin/keyd")
fi

# ── 3. Configure keyd ──
if [[ -x "$KEYD_BIN" ]] || command -v keyd &>/dev/null; then
    if [[ -f "$DOTFILES_DIR/keyd/default.conf" ]]; then
        echo "Applying keyd configuration..."
        sudo mkdir -p /etc/keyd
        sudo cp "$DOTFILES_DIR/keyd/default.conf" /etc/keyd/default.conf
        
        echo "Restarting and enabling keyd service..."
        sudo systemctl enable keyd
        sudo systemctl restart keyd
        
        # Force reload config using the specific binary
        if [[ -x "$KEYD_BIN" ]]; then
            sudo "$KEYD_BIN" reload
        else
            sudo keyd reload
        fi
        echo "keyd setup complete!"
    else
        echo "Error: keyd/default.conf not found in $DOTFILES_DIR"
        exit 1
    fi
else
    echo "ERROR: keyd is not installed. Please run install.sh again."
    exit 1
fi

echo ""
echo "macOS keybindings applied!"
echo "Your Physical Alt (next to spacebar) is now your Command key."
echo "Cmd+C and Cmd+V will now Copy/Paste system-wide."
echo ""
