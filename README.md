# Dotfiles

Cross-platform terminal setup: Ubuntu/Debian, Amazon Linux/RHEL/Fedora, macOS.

## What's included

- **zsh** with autosuggestions, syntax highlighting, and completions
- **Starship** prompt (fast, customizable, cross-shell)
- **tmux** with Catppuccin-inspired theme, sensible defaults
- **Alacritty** config (GPU-accelerated terminal)
- **Ghostty** config (GPU-accelerated terminal)
- **JetBrainsMono Nerd Font**

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
├── starship/starship.toml  # Prompt config
├── tmux/tmux.conf          # Tmux config
├── alacritty/alacritty.toml
├── ghostty/config
└── .gitignore
```

## Local overrides

Create `~/.zshrc.local` for machine-specific settings (not tracked by git).
