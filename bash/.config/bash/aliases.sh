# Aliases and Functions

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# File Listing (eza or ls)
if command -v eza &> /dev/null; then 
    alias ls='eza -lh --group-directories-first --icons=auto'
    alias lsa='ls -a' 
    alias lt='eza --tree --level=2 --long --icons --git' 
    alias lta='lt -a' 
else
    # Fallback to standard ls with colors
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
