# --- fzf config start ---
# Use fd (or find) instead of default find — faster & respects ignore rules
export FZF_DEFAULT_COMMAND="fd . --hidden --type f --exclude .git ~"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd . --hidden --type d --exclude .git ~"

# Optional: default fzf options — layout, preview, colors
export FZF_DEFAULT_OPTS="
  --height 50% \
  --layout=reverse \
  --border \
  --ansi \
  --preview 'bat --style=numbers --color=always {}' \
  --bind 'ctrl-/:toggle-preview' \
"

# Source fzf shell integration (you already have this)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# --- fzf config end ---

