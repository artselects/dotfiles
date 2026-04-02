# Dotfiles

Cross-platform terminal setup: Ubuntu/Debian, Amazon Linux/RHEL/Fedora, macOS.

## What's included

- **zsh** with autosuggestions, syntax highlighting, and completions
- **tmux** with Catppuccin-inspired theme, sensible defaults
- **Alacritty** config (GPU-accelerated terminal)
- **Ghostty** config (GPU-accelerated terminal)
- **JetBrainsMono Nerd Font**
- **keyd** macOS-like keybindings on Linux

## Install

```bash
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Structure

```
dotfiles/
├── install.sh              # One-command setup
├── zsh/.zshrc              # Zsh config
├── tmux/tmux.conf          # Tmux config
├── alacritty/alacritty.toml
├── ghostty/config
├── keyd/default.conf       # macOS-like key remapping (Linux)
├── scripts/remap-keys.sh   # keyd install helper
└── .gitignore
```

## Local overrides

Create `~/.zshrc.local` for machine-specific settings (not tracked by git).
