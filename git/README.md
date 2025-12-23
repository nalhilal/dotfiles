# Git Configuration

Git configuration with machine-specific local config support.

## Features

- Common aliases and settings
- `config.local` for user-specific settings (name, email, credentials) - not version controlled
- Shell aliases: `g`, `gcm`, `gcam`, `gcad` (configured in bash/zsh dotfiles)

## Installation

```bash
./install.sh git
```

Edit `~/.config/git/config.local` to add your user name and email.
