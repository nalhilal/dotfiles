# Zsh Environment Variables
# This file is sourced for all shells (login, interactive, non-interactive)

# Add local bin to PATH (portable)
export PATH="$HOME/.local/bin:$PATH"

# Load machine-specific environment variables (not version controlled)
if [[ -f "$ZDOTDIR/.zshenv.local" ]]; then
  source "$ZDOTDIR/.zshenv.local"
fi
