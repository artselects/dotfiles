# ── Dotfiles .zshrc ──────────────────────────────────────────────

# ── Prompt ──
precmd() { printf '%s\n' "${(l:COLUMNS::-:)}" }
PROMPT='%F{blue}%~%f %F{green}$%f '

# ── Early local overrides (env setup, PATH, etc.) ──
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# ── History ──
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY

# ── Completion ──
# Ensure system zsh functions are in fpath
fpath=($fpath /usr/share/zsh/${ZSH_VERSION}/functions /usr/share/zsh/site-functions /usr/local/share/zsh/site-functions)
[[ -d ~/.zsh/zsh-completions/src ]] && fpath=(~/.zsh/zsh-completions/src $fpath)
autoload -Uz add-zsh-hook is-at-least
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select

# ── Path ──
typeset -U path
path=(~/.local/bin $path)

# ── Plugins ──
_source_if_exists() { [[ -f "$1" ]] && source "$1"; }

_source_if_exists ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
_source_if_exists ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autosuggestion config
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Tab: accept autosuggestion if visible, otherwise do normal completion
_accept_or_complete() {
    if [[ -n "$POSTDISPLAY" ]]; then
        zle autosuggest-accept
    else
        zle expand-or-complete
    fi
}
zle -N _accept_or_complete
bindkey '\t' _accept_or_complete

# ── Aliases ──
if command -v eza &>/dev/null; then
    alias ls='eza'
    alias ll='eza -lah --git'
    alias la='eza -a'
    alias tree='eza --tree'
else
    alias ls='ls --color=auto 2>/dev/null || ls -G'
    alias ll='ls -lah'
    alias la='ls -A'
fi

if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
    export BAT_THEME="Catppuccin Mocha"
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
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi
    export FZF_DEFAULT_OPTS='--height 40% --border --info=inline --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8,fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc,marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
    _source_if_exists /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    _source_if_exists /opt/homebrew/opt/fzf/shell/completion.zsh
    _source_if_exists /usr/share/doc/fzf/examples/key-bindings.zsh
    _source_if_exists /usr/share/doc/fzf/examples/completion.zsh
fi

# ── Amazon dev tools (brazil, toolbox, ada) ──
_source_if_exists "$(dirname "$(readlink -f ~/.zshrc 2>/dev/null || echo ~/.zshrc)")/amazon.zsh"
