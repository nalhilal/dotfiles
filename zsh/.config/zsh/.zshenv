# Zsh Environment Variables
# This file is sourced for all shells (login, interactive, non-interactive)

# Set up Homebrew PATH (macOS)
if [[ -f /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Add local bin to PATH (portable)
export PATH="$HOME/.local/bin:$PATH"

# Load machine-specific environment variables (not version controlled)
if [[ -f "$ZDOTDIR/.zshenv.local" ]]; then
  source "$ZDOTDIR/.zshenv.local"
fi
