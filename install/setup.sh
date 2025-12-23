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

    case "$current_shell" in
        bash)
            # Check if bash dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/bash/bashrc" ]; then
                print_warning "Bash dotfiles are not installed. Starship configuration relies on them."
                print_info "Please install 'bash' package first to enable the dotfiles configuration."
            else
                print_success "Bash dotfiles detected"
            fi

            # Check for local conflicts in ~/.bashrc
            if [ -f "$HOME/.bashrc" ]; then
                if grep -E "^[[:space:]]*eval.*starship init" "$HOME/.bashrc" > /dev/null; then
                    print_warning "Detected manual Starship initialization in ~/.bashrc:"
                    grep -E "^[[:space:]]*eval.*starship init" "$HOME/.bashrc" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local init to use the dotfiles version?${NC} [y/N]: ")" fix_bashrc
                    if [ "$fix_bashrc" = "y" ] || [ "$fix_bashrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*eval.*starship init\)/# \1/' "$HOME/.bashrc"
                        print_success "Commented out local Starship init in ~/.bashrc"
                    else
                        print_info "Kept local init."
                    fi
                fi
            fi
            ;;
        zsh)
            # Check if zsh dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/zsh/.zshrc" ] && [ ! -n "$ZDOTDIR" ]; then
                print_warning "Zsh dotfiles are not installed. Starship configuration relies on them."
                print_info "Please install 'zsh' package first to enable the dotfiles configuration."
            else
                print_success "Zsh dotfiles detected"
            fi

            # Check for local conflicts in ~/.config/zsh/.zshrc.local
            local zsh_local="$HOME/.config/zsh/.zshrc.local"
            if [ -f "$zsh_local" ]; then
                if grep -E "^[[:space:]]*eval.*starship init" "$zsh_local" > /dev/null; then
                    print_warning "Detected manual Starship initialization in $zsh_local:"
                    grep -E "^[[:space:]]*eval.*starship init" "$zsh_local" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local init to use the dotfiles version?${NC} [y/N]: ")" fix_zshrc
                    if [ "$fix_zshrc" = "y" ] || [ "$fix_zshrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*eval.*starship init\)/# \1/' "$zsh_local"
                        print_success "Commented out local Starship init in $zsh_local"
                    else
                        print_info "Kept local init."
                    fi
                fi
            fi
            
            # Also check ~/.zshrc if it exists and is NOT a symlink to dotfiles (standard user zshrc)
            if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
                 if grep -E "^[[:space:]]*eval.*starship init" "$HOME/.zshrc" > /dev/null; then
                    print_warning "Detected manual Starship initialization in ~/.zshrc:"
                    grep -E "^[[:space:]]*eval.*starship init" "$HOME/.zshrc" | head -n 1
                    
                    echo ""
                    print_info "Since you are using dotfiles (ZDOTDIR), this file might be ignored or cause conflicts."
                fi
            fi
            ;;
        *)
            print_warning "Unsupported shell for automatic setup: $current_shell"
            ;;
    esac

    print_success "Starship setup complete!"
    print_info "Reload your shell to see changes: ${CYAN}exec $current_shell${NC}"
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

    case "$current_shell" in
        bash)
             # Check if bash dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/bash/bashrc" ]; then
                print_warning "Bash dotfiles are not installed. Zoxide configuration relies on them."
                print_info "Please install 'bash' package first to enable the dotfiles configuration."
            else
                print_success "Bash dotfiles detected"
            fi

            # Check for local conflicts in ~/.bashrc
            if [ -f "$HOME/.bashrc" ]; then
                if grep -E "^[[:space:]]*eval.*zoxide init" "$HOME/.bashrc" > /dev/null; then
                    print_warning "Detected manual zoxide initialization in ~/.bashrc:"
                    grep -E "^[[:space:]]*eval.*zoxide init" "$HOME/.bashrc" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local init to use the dotfiles version?${NC} [y/N]: ")" fix_bashrc
                    if [ "$fix_bashrc" = "y" ] || [ "$fix_bashrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*eval.*zoxide init\)/# \1/' "$HOME/.bashrc"
                        print_success "Commented out local zoxide init in ~/.bashrc"
                    else
                        print_info "Kept local init."
                    fi
                fi
            fi
            ;;
        zsh)
             # Check if zsh dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/zsh/.zshrc" ] && [ ! -n "$ZDOTDIR" ]; then
                print_warning "Zsh dotfiles are not installed. Zoxide configuration relies on them."
                print_info "Please install 'zsh' package first to enable the dotfiles configuration."
            else
                print_success "Zsh dotfiles detected"
            fi

            # Check for local conflicts in ~/.config/zsh/.zshrc.local
            local zsh_local="$HOME/.config/zsh/.zshrc.local"
            if [ -f "$zsh_local" ]; then
                if grep -E "^[[:space:]]*eval.*zoxide init" "$zsh_local" > /dev/null; then
                    print_warning "Detected manual zoxide initialization in $zsh_local:"
                    grep -E "^[[:space:]]*eval.*zoxide init" "$zsh_local" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local init to use the dotfiles version?${NC} [y/N]: ")" fix_zshrc
                    if [ "$fix_zshrc" = "y" ] || [ "$fix_zshrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*eval.*zoxide init\)/# \1/' "$zsh_local"
                        print_success "Commented out local zoxide init in $zsh_local"
                    else
                        print_info "Kept local init."
                    fi
                fi
            fi
            ;;
        *)
            print_warning "Unsupported shell for automatic setup: $current_shell"
            ;;
    esac

    print_success "Zoxide setup complete!"
    print_info "Reload your shell to use zoxide: ${CYAN}exec $current_shell${NC}"
    print_info "Use ${CYAN}z <directory>${NC} to jump to frequently used directories"
    return 0
}


setup_eza() {
    print_info "Setting up eza (modern ls replacement)..."

    # Check if eza binary is installed
    if ! check_binary_installed "eza"; then
        print_warning "eza binary is not installed"
        echo ""
        read -rp "$(echo -e "${BLUE}Would you like to install eza now?${NC} [Y/n]: ")" install_confirm

        if [ "$install_confirm" != "n" ] && [ "$install_confirm" != "N" ]; then
            if ! install_binary "eza"; then
                print_error "eza installation failed"
                print_info "You can install it manually later with: ${CYAN}$(get_install_command eza)${NC}"
                return 1
            fi
        else
            print_info "Skipping eza binary installation"
            print_info "Install it later with: ${CYAN}$(get_install_command eza)${NC}"
            return 1
        fi
    else
        print_success "eza binary is already installed"
    fi

    echo ""

    # Detect current shell and confirm alias setup
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Detected shell: ${CYAN}$current_shell${NC}"

    case "$current_shell" in
        bash)
            # Check for dotfiles configuration
            if [ -f "$HOME/.config/bash/aliases.sh" ]; then
                print_success "Bash aliases for eza are configured in ~/.config/bash/aliases.sh"
            else
                print_warning "Bash aliases file not found. Ensure you have installed the bash dotfiles."
            fi

            # Check for local conflicts in ~/.bashrc
            if [ -f "$HOME/.bashrc" ]; then
                # Look for aliases to ls that are NOT commented out
                if grep -E "^[[:space:]]*alias ls=" "$HOME/.bashrc" > /dev/null; then
                    print_warning "Detected local 'ls' alias in ~/.bashrc that might override eza:"
                    grep -E "^[[:space:]]*alias ls=" "$HOME/.bashrc" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local alias to use eza?${NC} [y/N]: ")" fix_bashrc
                    if [ "$fix_bashrc" = "y" ] || [ "$fix_bashrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*alias ls=\)/# \1/' "$HOME/.bashrc"
                        print_success "Commented out local 'ls' alias in ~/.bashrc"
                    else
                        print_info "Kept local alias. eza might not be the default 'ls'."
                    fi
                fi
            fi
            ;;
        zsh)
            # Check for dotfiles configuration
            if [ -f "$HOME/.config/zsh/extras.zsh" ]; then
                print_success "Zsh aliases for eza are configured in ~/.config/zsh/extras.zsh"
            else
                print_warning "Zsh extras file not found. Ensure you have installed the zsh dotfiles."
            fi

            # Check for local conflicts in ~/.config/zsh/.zshrc.local
            local zsh_local="$HOME/.config/zsh/.zshrc.local"
            if [ -f "$zsh_local" ]; then
                 # Look for aliases to ls that are NOT commented out
                if grep -E "^[[:space:]]*alias ls=" "$zsh_local" > /dev/null; then
                    print_warning "Detected local 'ls' alias in $zsh_local that might override eza:"
                    grep -E "^[[:space:]]*alias ls=" "$zsh_local" | head -n 1
                    
                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local alias to use eza?${NC} [y/N]: ")" fix_zshrc
                    if [ "$fix_zshrc" = "y" ] || [ "$fix_zshrc" = "Y" ]; then
                        sed -i 's/^\([[:space:]]*alias ls=\)/# \1/' "$zsh_local"
                        print_success "Commented out local 'ls' alias in $zsh_local"
                    else
                        print_info "Kept local alias. eza might not be the default 'ls'."
                    fi
                fi
            fi
            ;;
        *)
            print_warning "Unsupported shell for automatic alias verification: $current_shell"
            ;;
    esac

    print_success "eza setup complete!"
    return 0
}

setup_bat() {
    print_info "Setting up bat (better cat with syntax highlighting)..."

    # Check if bat binary is installed
    if ! check_binary_installed "bat"; then
        print_warning "bat binary is not installed"
        echo ""
        read -rp "$(echo -e "${BLUE}Would you like to install bat now?${NC} [Y/n]: ")" install_confirm

        if [ "$install_confirm" != "n" ] && [ "$install_confirm" != "N" ]; then
            if ! install_binary "bat"; then
                print_error "bat installation failed"
                print_info "You can install it manually later with: ${CYAN}$(get_install_command bat)${NC}"
                return 1
            fi
        else
            print_info "Skipping bat binary installation"
            print_info "Install it later with: ${CYAN}$(get_install_command bat)${NC}"
            return 1
        fi
    else
        print_success "bat binary is already installed"
    fi

    echo ""

    # Detect current shell
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Detected shell: ${CYAN}$current_shell${NC}"

    case "$current_shell" in
        bash)
            # Check if bash dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/bash/bashrc" ]; then
                print_warning "Bash dotfiles are not installed. Bat aliases rely on them."
                print_info "Please install 'bash' package first to enable the dotfiles configuration."
            else
                print_success "Bash dotfiles detected"
            fi

            # Check for conflicting cat alias in ~/.bashrc
            if [ -f "$HOME/.bashrc" ]; then
                if grep -E "^[[:space:]]*alias cat=" "$HOME/.bashrc" > /dev/null; then
                    print_warning "Detected local 'cat' alias in ~/.bashrc that might conflict with bat:"
                    grep -E "^[[:space:]]*alias cat=" "$HOME/.bashrc" | head -n 1

                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local alias to use bat?${NC} [y/N]: ")" fix_bashrc
                    if [ "$fix_bashrc" = "y" ] || [ "$fix_bashrc" = "Y" ]; then
                        sed -i '' 's/^\([[:space:]]*alias cat=\)/# \1/' "$HOME/.bashrc"
                        print_success "Commented out local 'cat' alias in ~/.bashrc"
                    else
                        print_info "Kept local alias. Bat aliases might not work as expected."
                    fi
                fi
            fi
            ;;
        zsh)
            # Check if zsh dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/zsh/.zshrc" ] && [ ! -n "$ZDOTDIR" ]; then
                print_warning "Zsh dotfiles are not installed. Bat aliases rely on them."
                print_info "Please install 'zsh' package first to enable the dotfiles configuration."
            else
                print_success "Zsh dotfiles detected"
            fi

            # Check for conflicting cat alias in ~/.config/zsh/.zshrc.local
            local zsh_local="$HOME/.config/zsh/.zshrc.local"
            if [ -f "$zsh_local" ]; then
                if grep -E "^[[:space:]]*alias cat=" "$zsh_local" > /dev/null; then
                    print_warning "Detected local 'cat' alias in $zsh_local that might conflict with bat:"
                    grep -E "^[[:space:]]*alias cat=" "$zsh_local" | head -n 1

                    echo ""
                    read -rp "$(echo -e "${BLUE}Would you like to comment out this local alias to use bat?${NC} [y/N]: ")" fix_zshrc
                    if [ "$fix_zshrc" = "y" ] || [ "$fix_zshrc" = "Y" ]; then
                        sed -i '' 's/^\([[:space:]]*alias cat=\)/# \1/' "$zsh_local"
                        print_success "Commented out local 'cat' alias in $zsh_local"
                    else
                        print_info "Kept local alias. Bat aliases might not work as expected."
                    fi
                fi
            fi
            ;;
        *)
            print_warning "Unsupported shell for automatic setup: $current_shell"
            ;;
    esac

    print_success "Bat setup complete!"
    print_info "Bat aliases enabled: ${CYAN}cat${NC} (bat with no paging), ${CYAN}less${NC} (bat with paging)"
    print_info "Reload your shell to see changes: ${CYAN}exec $current_shell${NC}"
    return 0
}

setup_fzf() {
    print_info "Setting up fzf (fuzzy finder)..."

    # Check if fzf binary is installed
    if ! check_binary_installed "fzf"; then
        print_warning "fzf binary is not installed"
        echo ""
        read -rp "$(echo -e "${BLUE}Would you like to install fzf now?${NC} [Y/n]: ")" install_confirm

        if [ "$install_confirm" != "n" ] && [ "$install_confirm" != "N" ]; then
            if ! install_binary "fzf"; then
                print_error "fzf installation failed"
                print_info "You can install it manually later with: ${CYAN}$(get_install_command fzf)${NC}"
                return 1
            fi
        else
            print_info "Skipping fzf binary installation"
            print_info "Install it later with: ${CYAN}$(get_install_command fzf)${NC}"
            return 1
        fi
    else
        print_success "fzf binary is already installed"
    fi

    echo ""

    # Detect current shell
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Detected shell: ${CYAN}$current_shell${NC}"

    case "$current_shell" in
        bash)
             # Check if bash dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/bash/bashrc" ]; then
                print_warning "Bash dotfiles are not installed. fzf configuration relies on them."
                print_info "Please install 'bash' package first to enable the dotfiles configuration."
            else
                print_success "Bash dotfiles detected"
            fi
            
            # Check for local conflicts/manual sourcing in ~/.bashrc
            if [ -f "$HOME/.bashrc" ]; then
                # Look for source ~/.fzf.bash which is standard
                if grep -E "^[[:space:]]*[.]?source.*/.fzf.bash" "$HOME/.bashrc" > /dev/null; then
                    print_info "Note: ~/.bashrc sources ~/.fzf.bash manually."
                fi
            fi
            ;;
        zsh)
             # Check if zsh dotfiles are installed (prerequisite)
            if [ ! -f "$HOME/.config/zsh/.zshrc" ] && [ ! -n "$ZDOTDIR" ]; then
                print_warning "Zsh dotfiles are not installed. fzf configuration relies on them."
                print_info "Please install 'zsh' package first to enable the dotfiles configuration."
            else
                print_success "Zsh dotfiles detected"
            fi
            ;;
    esac

    print_success "fzf setup complete!"
    return 0
}
