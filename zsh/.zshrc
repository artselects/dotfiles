# ── Dotfiles .zshrc ──────────────────────────────────────────────

# ── Powerlevel10k instant prompt (must be at top) ──
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My Zsh ──
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins (managed by oh-my-zsh)
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    docker
    kubectl
    fzf
    z
)

# Autosuggestion strategy
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source "$ZSH/oh-my-zsh.sh"

# ── History ──
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS

# ── Path ──
typeset -U path
path=(~/.local/bin $path)

# ── Aliases ──
# Use modern replacements if available
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -lah --icons --git'
    alias la='eza -a --icons'
    alias tree='eza --tree --icons'
else
    alias ls='ls --color=auto 2>/dev/null || ls -G'
    alias ll='ls -lah'
    alias la='ls -A'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

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

# ── fzf ──
if command -v fzf &>/dev/null; then
    # Use fd if available for better fzf performance
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    export FZF_DEFAULT_OPTS='--height 40% --border --info=inline'
fi

# ── Powerlevel10k config ──
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ── Local overrides (not tracked) ──
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
