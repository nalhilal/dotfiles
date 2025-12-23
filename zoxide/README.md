# Zoxide Configuration

A smarter cd command that remembers your most used directories.

## Features

- Fast navigation to frequently used paths
- Integration with bash and zsh shells
- Interactive selection
- Configured to use `cd` as the command alias

## Shell Integration

Automatically initialized in bash/zsh dotfiles via `eval "$(zoxide init <shell> --cmd cd)"`.

## Installation

```bash
./install.sh zoxide
```

The installer checks for the zoxide binary and offers to install it if missing. Detects conflicts with existing manual initializations in shell RC files.

## Usage

After installation, use `z <directory>` to jump to frequently used directories.
