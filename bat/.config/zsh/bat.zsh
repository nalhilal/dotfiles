# Bat aliases for Zsh
# Requires bat to be installed

# Only set up aliases if bat is available
if command -v bat &> /dev/null; then
    # Replace cat with bat (no paging, full output with syntax highlighting)
    alias cat='bat --paging=never'

    # Bat with paging (useful for large files)
    alias less='bat'

    # Bat with plain style (like cat but with syntax highlighting)
    alias catp='bat --style=plain'

    # Show bat help
    alias bathelp='bat --help'
fi
