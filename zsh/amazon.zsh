# Brazil/Amazon dev tool aliases
# Sourced automatically if brazil toolchain is detected

if command -v brazil &>/dev/null; then
    alias bb='brazil-build release'
    alias bba='brazil-build apollo-pkg'
    alias bre='brazil-runtime-exec'
    alias brc='brazil-recursive-cmd'
    alias bws='brazil ws'
    alias bwsuse='bws use -p'
    alias bwscreate='bws create -n'
    alias bbr='brc brazil-build'
    alias bball='brc --allPackages'
    alias bbb='brc --allPackages brazil-build'
    alias bbra='bbr apollo-pkg'
fi

if command -v ada &>/dev/null; then
    alias ad='ada credentials update'
fi

if command -v toolbox &>/dev/null; then
    export PATH="$HOME/.toolbox/bin:$PATH"
fi

[[ -f "$HOME/.brazil_completion/zsh_completion" ]] && source "$HOME/.brazil_completion/zsh_completion"
