# Bash Configuration

Modular Bash configuration using the **dotfiles as extension pattern**.

## Structure

**System Files** (automatically configured by installer):
- `~/.bashrc` - Minimally modified to source `~/.config/bash/bashrc`
- `~/.bash_profile` - Minimally modified to source `~/.config/bash/bash_profile`

**Dotfiles Configuration** (located in `~/.config/bash/`):
- `bashrc` - Main configuration, sources modular files and initializes tools (starship, zoxide, fzf, bat manpager)
- `bash_profile` - Login shell configuration
- `settings.sh` - History settings, shell options, environment variables
- `aliases.sh` - All aliases (eza, git, nvim, navigation shortcuts)

**Local Overrides**:
- `~/.bashrc.local` - Machine-specific configuration (not version controlled)

## Installation

```bash
./install.sh bash
```

The installer automatically sets up your system `.bashrc` and `.bash_profile` to source the dotfiles configurations.
