#!/usr/bin/env bash

setup_bash() {
    print_info "Setting up bash configuration..."

    # 1. Update .bashrc
    local bashrc="$HOME/.bashrc"
    if [ ! -f "$bashrc" ]; then
        touch "$bashrc"
        print_info "Created empty $bashrc"
    fi

    if ! grep -q "source.*\.config/bash/bashrc" "$bashrc"; then
        print_info "Appending source command to $bashrc"
        cat >> "$bashrc" << 'EOF'

# Source dotfiles bash config
if [ -f "$HOME/.config/bash/bashrc" ]; then
    source "$HOME/.config/bash/bashrc"
fi
EOF
        print_success "Updated $bashrc"
    else
        print_info "Bash config already sourced in $bashrc"
    fi

    # 2. Update .bash_profile (for login shells)
    local profile="$HOME/.bash_profile"
    # If .bash_profile doesn't exist but .profile does, use .profile?
    # Usually safer to just stick to .bash_profile for user-specific bash login stuff.
    if [ ! -f "$profile" ]; then
        touch "$profile"
        print_info "Created empty $profile"
    fi

    if ! grep -q "source.*\.config/bash/bash_profile" "$profile"; then
        print_info "Appending source command to $profile"
        cat >> "$profile" << 'EOF'

# Source dotfiles bash profile
if [ -f "$HOME/.config/bash/bash_profile" ]; then
    source "$HOME/.config/bash/bash_profile"
fi
EOF
        print_success "Updated $profile"
    else
        print_info "Bash profile already sourced in $profile"
    fi

    return 0
}

setup_tmux() {
    print_info "Setting up tmux plugins..."

    # Tmux plugins are managed as git submodules
    # Check if submodules are initialized
    if [ ! -f "$DOTFILES_DIR/tmux/.config/tmux/plugins/tpm/tpm" ]; then
        print_info "Initializing tmux plugin submodules..."

        cd "$DOTFILES_DIR" || {
            print_error "Failed to change to dotfiles directory"
            return 1
        }

        if git submodule update --init --recursive -- tmux/.config/tmux/plugins 2>&1 | grep -q "Cloning\|Submodule"; then
            print_success "Tmux plugins initialized successfully"
        else
            print_error "Failed to initialize tmux plugin submodules"
            print_info "You can manually run: ${CYAN}cd $DOTFILES_DIR && git submodule update --init --recursive${NC}"
            return 1
        fi
    else
        print_info "Tmux plugins already initialized"
    fi

    print_success "Tmux setup complete!"
    print_info "Start tmux and the plugins will load automatically"
    print_info "Or reload tmux config with: ${CYAN}Ctrl+Space then r${NC}"
    return 0
}

setup_lazygit() {
    print_info "Setting up lazygit configuration..."
    local os=$(detect_os)

    # On macOS, lazygit looks for config in ~/Library/Application Support/lazygit/
    # We need to create a symlink from there to our stowed config in ~/.config/lazygit/
    if [ "$os" = "macos" ]; then
        local macos_config_dir="$HOME/Library/Application Support/lazygit"
        local xdg_config_dir="$HOME/.config/lazygit"

        # Create the macOS directory if it doesn't exist
        if [ ! -d "$macos_config_dir" ]; then
            mkdir -p "$macos_config_dir" || {
                print_error "Failed to create macOS lazygit directory"
                return 1
            }
        fi

        # Create symlink for config.yml
        if [ ! -e "$macos_config_dir/config.yml" ]; then
            ln -s "$xdg_config_dir/config.yml" "$macos_config_dir/config.yml" || {
                print_error "Failed to symlink lazygit config.yml"
                return 1
            }
            print_success "Created symlink: $macos_config_dir/config.yml -> $xdg_config_dir/config.yml"
        elif [ -L "$macos_config_dir/config.yml" ]; then
            print_info "lazygit config.yml symlink already exists"
        else
            print_warning "lazygit config.yml exists but is not a symlink"
            print_info "You may want to backup and replace it with: ln -sf $xdg_config_dir/config.yml $macos_config_dir/config.yml"
        fi

        # Also symlink ai-commit.sh if it exists
        if [ -f "$xdg_config_dir/ai-commit.sh" ]; then
            if [ ! -e "$macos_config_dir/ai-commit.sh" ]; then
                ln -s "$xdg_config_dir/ai-commit.sh" "$macos_config_dir/ai-commit.sh" || {
                    print_warning "Failed to symlink ai-commit.sh"
                }
                print_success "Created symlink: $macos_config_dir/ai-commit.sh -> $xdg_config_dir/ai-commit.sh"
            fi
        fi

        print_success "lazygit macOS configuration complete!"
    else
        print_info "lazygit uses XDG config directory on Linux"
    fi

    return 0
}

setup_zsh() {
    print_info "Setting up zsh configuration..."

    # Create ~/.zshenv if it doesn't exist
    if [ ! -f "$HOME/.zshenv" ]; then
        cat > "$HOME/.zshenv" << 'EOF' || {
# Set XDG-compliant zsh config directory
export ZDOTDIR="$HOME/.config/zsh"
EOF
            print_error "Failed to create ~/.zshenv"
            return 1
        }
        print_success "Created ~/.zshenv"
    else
        print_warning "~/.zshenv already exists, skipping..."
    fi

    # Create placeholder ~/.zshrc for installers
    if [ ! -f "$HOME/.zshrc" ]; then
        cat > "$HOME/.zshrc" << 'EOF' || {
# This file exists for installers that try to modify ~/.zshrc
# Zsh ignores this file because ZDOTDIR is set in ~/.zshenv
#
# If an installer adds something here, manually move it to:
# ~/.config/zsh/.zshrc.local (for machine-specific config)
#
# DO NOT source anything from here, as it would defeat the purpose of ZDOTDIR
EOF
            print_error "Failed to create ~/.zshrc"
            return 1
        }
        print_success "Created placeholder ~/.zshrc"
    else
        print_warning "~/.zshrc already exists, skipping..."
    fi

    # Create .zshrc.local if it doesn't exist
    if [ ! -f "$HOME/.config/zsh/.zshrc.local" ]; then
        cat > "$HOME/.config/zsh/.zshrc.local" << 'EOF' || {
# Machine-specific Zsh Configuration
# This file is NOT version controlled
# Add your machine-specific configurations here
#
# Examples:
# - PATH modifications for local tools
# - API keys and tokens
# - Tool initializations (conda, nvm, etc.)
EOF
            print_error "Failed to create ~/.config/zsh/.zshrc.local"
            return 1
        }
        print_success "Created ~/.config/zsh/.zshrc.local"
    else
        print_info ".zshrc.local already exists, preserving..."
    fi

    # Manually symlink .gitignore if stow didn't (it sometimes skips it)
    if [ ! -e "$HOME/.config/zsh/.gitignore" ]; then
        if [ -f "$DOTFILES_DIR/zsh/.config/zsh/.gitignore" ]; then
            ln -s "$DOTFILES_DIR/zsh/.config/zsh/.gitignore" "$HOME/.config/zsh/.gitignore" || {
                print_warning "Failed to symlink .gitignore"
            }
            print_success "Symlinked .gitignore"
        else
            print_warning ".gitignore not found in dotfiles, skipping..."
        fi
    fi

    print_success "Zsh setup complete!"
    print_info "Run ${CYAN}exec zsh${NC} or ${CYAN}source ~/.zshenv${NC} to apply changes"
    return 0
}

setup_git() {
    print_info "Setting up git configuration..."

    # Create config.local if it doesn't exist
    if [ ! -f "$HOME/.config/git/config.local" ]; then
        cat > "$HOME/.config/git/config.local" << 'EOF' || {
# Machine-specific Git Configuration
# This file is NOT version controlled
# Add your machine-specific configurations here
#
# Example:
# [user]
# 	name = Your Name
# 	email = your.email@example.com
#
# [credential]
# 	helper = osxkeychain  # macOS
#	helper = store        # Linux
EOF
            print_error "Failed to create ~/.config/git/config.local"
            return 1
        }
        print_success "Created ~/.config/git/config.local"
        print_info "Edit ${CYAN}~/.config/git/config.local${NC} to add your user name and email"
    else
        print_info "config.local already exists, preserving..."
    fi

    print_success "Git setup complete!"
    print_info "Set your user name and email in ${CYAN}~/.config/git/config.local${NC}"
    return 0
}

setup_starship() {
    print_info "Setting up Starship prompt..."

    # Check if starship binary is installed
    if ! check_binary_installed "starship"; then
        print_warning "Starship binary is not installed"
        echo ""
        read -rp "$(echo -e "${BLUE}Would you like to install starship now?${NC} [Y/n]: ")" install_confirm

        if [ "$install_confirm" != "n" ] && [ "$install_confirm" != "N" ]; then
            if ! install_binary "starship"; then
                print_error "Starship installation failed"
                print_info "You can install it manually later with: ${CYAN}$(get_install_command starship)${NC}"
                return 1
            fi
        else
            print_info "Skipping starship binary installation"
            print_info "Install it later with: ${CYAN}$(get_install_command starship)${NC}"
            return 1
        fi
    else
        print_success "Starship binary is already installed"
    fi

    echo ""

    # Detect current shell
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Detected shell: ${CYAN}$current_shell${NC}"

    # If current shell is zsh, offer to install zsh config
    if [ "$current_shell" = "zsh" ]; then
        echo ""
        print_info "Detected zsh as your shell"

        # Check if zsh config is already installed
        if ! is_already_stowed "zsh"; then
            read -rp "$(echo -e "${BLUE}Would you like to install the zsh configuration as well?${NC} [Y/n]: ")" zsh_confirm

            if [ "$zsh_confirm" != "n" ] && [ "$zsh_confirm" != "N" ]; then
                print_info "Installing zsh configuration..."
                if install_package "zsh"; then
                    print_success "Zsh configuration installed"
                else
                    print_warning "Zsh installation failed, continuing with starship setup"
                fi
            fi
        else
            print_info "Zsh configuration already installed"
        fi
    fi

    # Add starship initialization to shell rc file
    add_starship_to_shell "$current_shell"

    print_success "Starship setup complete!"
    print_info "Reload your shell to see changes: ${CYAN}exec $current_shell${NC}"
    return 0
}

add_starship_to_shell() {
    local shell=$1
    local rc_file=""
    local init_line=""

    case "$shell" in
        bash)
            if [ -f "$HOME/.config/bash/bashrc" ]; then
                rc_file="$HOME/.config/bash/bashrc"
            else
                rc_file="$HOME/.bashrc"
            fi
            init_line='eval "$(starship init bash)"'
            ;;
        zsh)
            # If using ZDOTDIR, add to the config zsh directory
            if [ -n "$ZDOTDIR" ] && [ -d "$ZDOTDIR" ]; then
                rc_file="$ZDOTDIR/.zshrc"
            elif [ -f "$HOME/.config/zsh/.zshrc" ]; then
                rc_file="$HOME/.config/zsh/.zshrc"
            else
                rc_file="$HOME/.zshrc"
            fi
            init_line='eval "$(starship init zsh)"'
            ;;
        fish)
            rc_file="$HOME/.config/fish/config.fish"
            init_line='starship init fish | source'
            ;;
        *)
            print_warning "Unknown shell: $shell"
            print_info "Add this to your shell RC file manually:"
            echo -e "  ${CYAN}eval \"\\$(starship init $shell)\"${NC}"
            return 1
            ;;
    esac

    # Check if rc file exists
    if [ ! -f "$rc_file" ]; then
        print_warning "Shell RC file not found: $rc_file"
        print_info "Creating it now..."
        mkdir -p "$(dirname "$rc_file")"
        touch "$rc_file"
    fi

    # Check if starship is already initialized
    if grep -q "starship init" "$rc_file" 2>/dev/null; then
        print_info "Starship already initialized in $rc_file"
        return 0
    fi

    # Add starship initialization
    echo "" >> "$rc_file"
    echo "# Initialize Starship prompt" >> "$rc_file"
    echo "$init_line" >> "$rc_file"

    print_success "Added starship initialization to $rc_file"
    return 0
}

setup_zoxide() {
    print_info "Setting up zoxide..."

    # Check if zoxide binary is installed
    if ! check_binary_installed "zoxide"; then
        print_warning "Zoxide binary is not installed"
        echo ""
        read -rp "$(echo -e "${BLUE}Would you like to install zoxide now?${NC} [Y/n]: ")" install_confirm

        if [ "$install_confirm" != "n" ] && [ "$install_confirm" != "N" ]; then
            if ! install_binary "zoxide"; then
                print_error "Zoxide installation failed"
                print_info "You can install it manually later with: ${CYAN}$(get_install_command zoxide)${NC}"
                return 1
            fi
        else
            print_info "Skipping zoxide binary installation"
            print_info "Install it later with: ${CYAN}$(get_install_command zoxide)${NC}"
            return 1
        fi
    else
        print_success "Zoxide binary is already installed"
    fi

    echo ""

    # Detect current shell
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Detected shell: ${CYAN}$current_shell${NC}"

    # Add zoxide initialization to shell rc file(s)
    add_zoxide_to_shell "$current_shell"

    print_success "Zoxide setup complete!"
    print_info "Reload your shell to use zoxide: ${CYAN}exec $current_shell${NC}"
    print_info "Use ${CYAN}z <directory>${NC} to jump to frequently used directories"
    return 0
}

add_zoxide_to_shell() {
    local shell=$1
    local rc_file=""
    local init_line=""

    case "$shell" in
        bash)
            if [ -f "$HOME/.config/bash/bashrc" ]; then
                rc_file="$HOME/.config/bash/bashrc"
            else
                rc_file="$HOME/.bashrc"
            fi
            init_line='eval "$(zoxide init bash)"'
            ;;
        zsh)
            # If using ZDOTDIR, add to the config zsh directory
            if [ -n "$ZDOTDIR" ] && [ -d "$ZDOTDIR" ]; then
                rc_file="$ZDOTDIR/.zshrc"
            elif [ -f "$HOME/.config/zsh/.zshrc" ]; then
                rc_file="$HOME/.config/zsh/.zshrc"
            else
                rc_file="$HOME/.zshrc"
            fi
            init_line='eval "$(zoxide init zsh)"'
            ;;
        fish)
            rc_file="$HOME/.config/fish/config.fish"
            init_line='zoxide init fish | source'
            ;;
        *)
            print_warning "Unknown shell: $shell"
            print_info "Add this to your shell RC file manually:"
            echo -e "  ${CYAN}eval \"\$(zoxide init $shell)\"${NC}"
            return 1
            ;;
    esac

    # Check if rc file exists
    if [ ! -f "$rc_file" ]; then
        print_warning "Shell RC file not found: $rc_file"
        print_info "Creating it now..."
        mkdir -p "$(dirname "$rc_file")"
        touch "$rc_file"
    fi

    # Check if zoxide is already initialized
    if grep -q "zoxide init" "$rc_file" 2>/dev/null; then
        print_info "Zoxide already initialized in $rc_file"
        return 0
    fi

    # Add zoxide initialization
    echo "" >> "$rc_file"
    echo "# Initialize zoxide (smarter cd)" >> "$rc_file"
    echo "$init_line" >> "$rc_file"

    print_success "Added zoxide initialization to $rc_file"
    return 0
}
