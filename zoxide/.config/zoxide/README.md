# Zoxide Configuration

Zoxide is a smarter `cd` command that learns your habits and helps you navigate faster.

## What it does

- Tracks directories you visit
- Jump to directories using partial names
- Works as a drop-in replacement for `cd`

## Usage

After installation, use `z` instead of `cd`:

```bash
z docs        # Jump to most frecent directory matching "docs"
z foo bar     # Jump to directory matching both "foo" and "bar"
zi docs       # Interactive selection with fzf
```

## Shell Integration

The install script automatically:
1. Installs the zoxide binary for your OS
2. Adds initialization to your shell RC file (bash/zsh)
3. Sets up the `cd` alias to use zoxide

## Manual Setup

If you need to add zoxide to a new shell manually:

```bash
# For Bash
echo 'eval "$(zoxide init bash)"' >> ~/.bashrc

# For Zsh
echo 'eval "$(zoxide init zsh)"' >> ~/.config/zsh/.zshrc
```
