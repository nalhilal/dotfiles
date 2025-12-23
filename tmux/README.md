# Tmux Configuration

Terminal multiplexer configuration with Synthwave 2077 theming.

## Features

- Vim-style keybindings for pane navigation (h/j/k/l)
- Seamless integration with Neovim via vim-tmux-navigator
- TPM (Tmux Plugin Manager) with useful plugins
- Session persistence with tmux-resurrect and tmux-continuum
- CPU/Memory monitoring display
- Custom status bar styling

## Plugins (managed as git submodules)

- `tpm` - Tmux Plugin Manager
- `vim-tmux-navigator` - Seamless navigation between tmux panes and vim splits
- `tmux-resurrect` - Save and restore tmux sessions
- `tmux-continuum` - Automatic session saving
- `tmux-cpu-mem-monitor` - System resource monitoring

## Installation

```bash
./install.sh tmux
```

The installer automatically initializes git submodules for tmux plugins. Plugins load automatically when tmux starts.

**Important**: Uses `~/.config/tmux/plugins/` (XDG directory) not `~/.tmux/plugins/`
