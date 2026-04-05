# Dotfiles

Cross-platform terminal setup: Ubuntu/Debian, Amazon Linux/RHEL/Fedora, macOS.

## What's included

- **zsh** with autosuggestions, syntax highlighting, and completions
- **tmux** with smart session manager (`t-session`), mouse toggle (`Prefix + m`), and Catppuccin-inspired theme
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
├── zsh/amazon.zsh          # Amazon dev tool aliases (brazil, ada, toolbox)
├── tmux/tmux.conf          # Tmux config
├── alacritty/alacritty.toml
├── ghostty/config
├── keyd/default.conf       # macOS-like key remapping (Linux)
├── scripts/tmux-session.sh   # Smart session manager (t-session)
├── scripts/remap-keys.sh     # keyd install helper
└── .gitignore
```

## Local overrides

Create `~/.zshrc.local` for machine-specific settings (not tracked by git).
