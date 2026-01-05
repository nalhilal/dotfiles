# Aliases and Functions

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# File Listing (eza or ls)
if command -v eza &>/dev/null; then
    # 1. Clear any existing ls alias so the function can take over
    unalias ls 2>/dev/null

    # 2. Define the function using the 'function' keyword
    function ls {
        local args=()
        local sort_flag=()

        for arg in "$@"; do
            case "$arg" in
            -lt) sort_flag=("--sort" "modified") ;;
            -lrt) sort_flag=("--sort" "modified" "--reverse") ;;
            *) args+=("$arg") ;;
            esac
        done

        # Apply the logic: default eza flags + any translated sort flags + original args
        eza -lh --color=always --group-directories-first --icons=auto --git "${sort_flag[@]}" "${args[@]}"
    }

    # 3. Rest of your aliases
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
    alias lm='ls --sort modified'
    alias lmr='ls --sort modified -r'
else
    # Fallback
    unalias ls 2>/dev/null
    if [[ "$OSTYPE" == "darwin"* ]]; then
        alias ls='ls -G'
    else
        alias ls='ls --color=auto'
    fi
    alias lsa='ls -la'
    alias ll='ls -l'
fi

# Git
alias g='git'
alias gcm='git commit -m'
alias gcam='git commit -a -m'
alias gcad='git commit -a --amend'

# Editor
alias v='nvim'
alias vim='nvim'

# Smart nvim opener (from Omarchy distro)
n() {
    if [ "$#" -eq 0 ]; then
        nvim .
    else
        nvim "$@"
    fi
}

# Grep colors
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Safety
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
