# from the Omarchy distro 
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Replacing ls with eza
# File system 
if (( $+commands[eza] )); then
    # 1. Clear any existing alias so the function takes precedence
    unalias ls 2>/dev/null

    # 2. Define the Zsh function
    ls() {
        local args=()
        local sort_args=()
        
        for arg in "$@"; do
            case "$arg" in
                -lt)  sort_args+=(--sort modified) ;;
                -lrt) sort_args+=(--sort modified --reverse) ;;
                *)    args+=("$arg") ;;
            esac
        done

        # Use 'command eza' to ensure we call the binary, not a loop
        command eza -lh --color=always --group-directories-first --icons=auto --git "${sort_args[@]}" "${args[@]}"
    }

    # 3. Aliases
    alias lsa='ls -a'
    alias lt='eza --tree --level=2 --long --icons --git'
    alias lta='lt -a'
    alias lm='ls --sort modified'
    alias lmr='ls --sort modified -r'
else
    # Fallback for standard ls
    unalias ls 2>/dev/null
    [[ "$OSTYPE" == "darwin"* ]] && alias ls='ls -G' || alias ls='ls --color=auto'
    alias lsa='ls -la'
    alias ll='ls -l'
fi

# ngrok
if command -v ngrok &>/dev/null; then
  eval "$(ngrok completion)"
fi

