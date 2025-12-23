# Lazygit Configuration

Terminal UI for git with custom command integration.

## Features

- AI-powered commit message generation using Claude Code
- Custom keybinding (C) for generating conventional commit messages
- Automatic commit message formatting with subject line and bullet points
- No AI attribution or extra commentary in commits

## Cross-Platform Support

- **macOS**: Config stored in `~/.config/lazygit/`, symlinked to `~/Library/Application Support/lazygit/`
- **Linux**: Config stored directly in `~/.config/lazygit/`

The installer handles platform-specific setup automatically.

## Installation

```bash
./install.sh lazygit
```
