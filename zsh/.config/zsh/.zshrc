# Zsh Configuration
# This file contains portable configuration for version control

# Homebrew completions (must be set before compinit)
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

# Initialize completion system
autoload -Uz compinit
compinit

# History Configuration
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000

# History Options
setopt EXTENDED_HISTORY          # Write timestamps to history
setopt INC_APPEND_HISTORY        # Write to history immediately
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicates first
setopt HIST_IGNORE_DUPS          # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicate entries
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt HIST_IGNORE_SPACE         # Ignore commands starting with space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicates
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Show command before executing from history

# Show full history by default
alias history='history 1'

# Homebrew: disable auto-update hints
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Zsh Syntax Highlighting: Synthwave 2077 theme
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# Synthwave 2077 syntax highlighting colors
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'           # Invalid commands
ZSH_HIGHLIGHT_STYLES[command]='fg=#72f1b8'                  # Valid commands (cyan)
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#00d4b1'                  # Builtins (teal)
ZSH_HIGHLIGHT_STYLES[alias]='fg=#ff7edb'                    # Aliases (pink)
ZSH_HIGHLIGHT_STYLES[function]='fg=#b893ce'                 # Functions (purple)
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#fede5d'         # Pipes, semicolons (neon green)
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#f3e70f'   # Single-quoted strings (yellow)
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#f3e70f'   # Double-quoted strings (yellow)
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#f3e70f'   # Dollar-quoted strings (yellow)
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#fede5d'     # Backticks (neon green)
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#00a2ff'     # Short options like -h (bright blue)
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#00a2ff'     # Long options like --help (bright blue)
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ff6b9d'              # Redirections like > < (bright pink)
ZSH_HIGHLIGHT_STYLES[comment]='fg=#311b92'                  # Comments (dark purple)
ZSH_HIGHLIGHT_STYLES[arg0]='fg=#72f1b8'                     # Command name (cyan)
ZSH_HIGHLIGHT_STYLES[default]='fg=#00d4b1'                  # Default text (teal)

# Load zsh plugins (if installed via Homebrew)
if [[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# Load modular configuration files
source "$ZDOTDIR/starship.zsh"
source "$ZDOTDIR/zoxide.zsh"
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/nvim.zsh"
source "$ZDOTDIR/extras.zsh"
source "$ZDOTDIR/git.zsh"

# Load bat aliases (if installed)
[[ -f "$ZDOTDIR/bat.zsh" ]] && source "$ZDOTDIR/bat.zsh"

# Load machine-specific configuration (not version controlled)
if [[ -f "$ZDOTDIR/.zshrc.local" ]]; then
  source "$ZDOTDIR/.zshrc.local"
fi

export MANPAGER="sh -c 'col -bx | bat -l man -p'"

echo ">>> USER .zshrc LOADED <<<"

