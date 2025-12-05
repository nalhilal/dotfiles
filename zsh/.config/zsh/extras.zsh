# from the Omarchy distro 
# Directories
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Replacing ls with eza
# File system 
if command -v eza &> /dev/null; then 
	alias ls='eza -lh --group-directories-first --icons=auto'
	alias lsa='ls -a' 
	alias lt='eza --tree --level=2 --long --icons --git' 
	alias lta='lt -a' 
fi

