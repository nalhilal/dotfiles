# Agent Guidance

Personal dotfiles for macOS and Linux using GNU Stow, with a Synthwave 2077 aesthetic.

**Full architecture and package details:** [CLAUDE.md](CLAUDE.md)

## Non-negotiables

- Use `stow` for symlinking package files — never `cp` or `ln` directly
- Shell RC files only source `~/.config/{zsh,bash}/`; tool config lives in dotfiles packages
- Only `setup_bash()` and `setup_zsh()` modify system RC files
- Run `./test_install.sh` before committing install logic changes
- No AI attribution or Co-Authored-By lines in commits
- Only create git commits when explicitly asked

## Common commands

```bash
./install.sh              # Interactive install
./install.sh nvim zsh     # Specific packages
./test_install.sh         # E2E install tests
stow -n <package>         # Dry-run stow (from ~/.dotfiles)
```

Package READMEs: [bash/](bash/README.md), [zsh/](zsh/README.md), [starship/](starship/README.md), and others listed in [CLAUDE.md](CLAUDE.md).

## Cursor workflow

- Prefer minimal, focused diffs; match existing conventions in surrounding code
- Tool shell init (`starship.zsh`, `bat.zsh`, etc.) belongs in **zsh/bash packages**; tool packages own configs only (see bat and starship)
- New UI configs should use the Synthwave 2077 palette: `#ff7edb`, `#b893ce`, `#72f1b8`, `#fede5d`
- Do not leave empty directories under `package/.config/` — stow may adopt or replace parent dirs
- Archive or historical configs belong outside `package/.config/` (e.g. `starship/archive/`)
- WezTerm always uses the dark Starship prompt (fixed dark color scheme); other terminals follow OS/`COLORFGBG` appearance
