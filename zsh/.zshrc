# ── Dotfiles .zshrc ──────────────────────────────────────────────

# History
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY

# Options
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# Completion
autoload -Uz compinit
compinit -C
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Key bindings (emacs style)
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Aliases
alias ls='ls --color=auto 2>/dev/null || ls -G'
alias ll='ls -lah'
alias la='ls -A'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias g='git'
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate -20'
alias gc='git commit'
alias gp='git push'
alias gpl='git pull'

# Path
typeset -U path
path=(~/.local/bin $path)

# ── Plugins (loaded via install script) ──
PLUGIN_DIR="${ZDOTDIR:-$HOME}/.zsh/plugins"

if [[ -f "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh"
    ZSH_AUTOSUGGEST_STRATEGY=(history completion)
fi

if [[ -f "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [[ -f "$PLUGIN_DIR/zsh-completions/zsh-completions.plugin.zsh" ]]; then
    fpath=("$PLUGIN_DIR/zsh-completions/src" $fpath)
fi

# ── Starship prompt ──
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# ── Local overrides (not tracked) ──
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
