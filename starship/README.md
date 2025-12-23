# Starship Prompt Configuration

Cross-shell prompt with custom Synthwave 2077 theme.

## Features

- OS-aware icon display (Arch, macOS, Ubuntu, Debian, Fedora, etc.)
- Color-coded directory display with icon substitutions
- Git branch and status indicators
- Language version display (Node.js, Rust, Go, PHP)
- Time display with matching color palette

## Shell Integration

Automatically initialized in bash/zsh dotfiles via `eval "$(starship init <shell>)"`.

## Installation

```bash
./install.sh starship
```

The installer checks for the starship binary and offers to install it if missing. Detects conflicts with existing manual initializations in shell RC files.
