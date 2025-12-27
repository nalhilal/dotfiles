#!/usr/bin/env bash

# Available packages
AVAILABLE_PACKAGES=("bash" "bat" "eza" "fzf" "git" "lazygit" "nvim" "starship" "tmux" "wezterm" "zoxide" "zsh")

is_already_stowed() {
    local package=$1
    local target_dir=""
    local source_dir=""
    local os=$(detect_os)

    case "$package" in
        bash)
            # Bash may have individual files stowed if the directory existed before stowing
            # Check if at least one key file is stowed correctly
            if [ -L "$HOME/.config/bash/bashrc" ]; then
                local link_target resolved_source
                link_target=$(get_absolute_path "$HOME/.config/bash/bashrc")
                resolved_source=$(get_absolute_path "$DOTFILES_DIR/bash/.config/bash/bashrc")
                if [[ "$link_target" == "$resolved_source" ]]; then
                    return 0
                fi
            fi
            # Fall back to checking if entire directory is stowed
            target_dir="$HOME/.config/bash"
            source_dir="$DOTFILES_DIR/bash/.config/bash"
            ;;
        bat)
            # Bat stows individual files, not directories
            # Check if at least one of the alias files is stowed
            if [ -L "$HOME/.config/bash/bat.sh" ]; then
                local link_target resolved_source
                link_target=$(get_absolute_path "$HOME/.config/bash/bat.sh")
                resolved_source=$(get_absolute_path "$DOTFILES_DIR/bat/.config/bash/bat.sh")
                if [[ "$link_target" == "$resolved_source" ]]; then
                    return 0
                fi
            fi
            return 1
            ;;
        eza|fzf)
            if check_binary_installed "$package"; then
                return 0
            fi
            return 1
            ;;
        git)
            target_dir="$HOME/.config/git"
            source_dir="$DOTFILES_DIR/git/.config/git"
            ;;
        nvim)
            target_dir="$HOME/.config/nvim"
            source_dir="$DOTFILES_DIR/nvim/.config/nvim"
            ;;
        lazygit)
            # lazygit has different default locations on macOS vs Linux
            if [ "$os" = "macos" ]; then
                # Check if macOS Library location is properly symlinked
                target_dir="$HOME/Library/Application Support/lazygit"
            else
                target_dir="$HOME/.config/lazygit"
            fi
            source_dir="$DOTFILES_DIR/lazygit/.config/lazygit"
            ;;
        starship)
            target_dir="$HOME/.config/starship.toml"
            source_dir="$DOTFILES_DIR/starship/.config/starship.toml"
            ;;
        tmux)
            target_dir="$HOME/.config/tmux"
            source_dir="$DOTFILES_DIR/tmux/.config/tmux"
            ;;
        wezterm)
            target_dir="$HOME/.config/wezterm"
            source_dir="$DOTFILES_DIR/wezterm/.config/wezterm"
            ;;
        zoxide)
            target_dir="$HOME/.config/zoxide"
            source_dir="$DOTFILES_DIR/zoxide/.config/zoxide"
            ;;
        zsh)
            target_dir="$HOME/.config/zsh"
            source_dir="$DOTFILES_DIR/zsh/.config/zsh"
            ;;
    esac

    # Check if it's a symlink pointing to our dotfiles
    if [ -L "$target_dir" ]; then
        local link_target resolved_source
        # Get absolute path of symlink target
        link_target=$(get_absolute_path "$target_dir")
        # Also resolve source_dir to handle /var vs /private/var on macOS
        resolved_source=$(get_absolute_path "$source_dir")
        # Check if it points to our dotfiles directory
        if [[ "$link_target" == "$resolved_source" ]]; then
            return 0  # Already correctly stowed
        fi
    fi

    # For lazygit on macOS, also check if config.yml is symlinked
    if [ "$package" = "lazygit" ] && [ "$os" = "macos" ]; then
        if [ -L "$HOME/Library/Application Support/lazygit/config.yml" ]; then
            local link_target resolved_target
            link_target=$(get_absolute_path "$HOME/Library/Application Support/lazygit/config.yml")
            resolved_target=$(get_absolute_path "$HOME/.config/lazygit/config.yml")
            if [[ "$link_target" == "$resolved_target" ]]; then
                return 0  # Already correctly configured
            fi
        fi
    fi

    return 1
}

backup_existing() {
    local package=$1
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    local os=$(detect_os)

    case "$package" in
        bash)
            if [ -e "$HOME/.config/bash" ] && [ ! -L "$HOME/.config/bash" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/bash" "$backup_dir/"
                print_warning "Backed up existing bash config dir to: $backup_dir"
            fi
            ;;
        bat)
            # Bat stows individual files, check and backup each
            local backed_up=0
            if [ -e "$HOME/.config/bash/bat.sh" ] && [ ! -L "$HOME/.config/bash/bat.sh" ]; then
                mkdir -p "$backup_dir/bat" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/bash/bat.sh" "$backup_dir/bat/" || {
                    print_error "Failed to backup bat.sh"
                    return 1
                }
                backed_up=1
            fi
            if [ -e "$HOME/.config/zsh/bat.zsh" ] && [ ! -L "$HOME/.config/zsh/bat.zsh" ]; then
                mkdir -p "$backup_dir/bat" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/zsh/bat.zsh" "$backup_dir/bat/" || {
                    print_error "Failed to backup bat.zsh"
                    return 1
                }
                backed_up=1
            fi
            if [ $backed_up -eq 1 ]; then
                print_warning "Backed up existing bat aliases to: $backup_dir/bat"
            fi
            ;;
        git)
            if [ -e "$HOME/.config/git" ] && [ ! -L "$HOME/.config/git" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                # Backup but preserve config.local if it exists
                if [ -f "$HOME/.config/git/config.local" ]; then
                    cp "$HOME/.config/git/config.local" "$backup_dir/config.local.keep" || {
                        print_warning "Failed to preserve config.local"
                    }
                fi
                mv "$HOME/.config/git" "$backup_dir/" || {
                    print_error "Failed to backup git config"
                    return 1
                }
                print_warning "Backed up existing git config to: $backup_dir"
            fi
            ;;
        nvim)
            if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/nvim" "$backup_dir/" || {
                    print_error "Failed to backup nvim config"
                    return 1
                }
                print_warning "Backed up existing nvim config to: $backup_dir"
            fi
            ;;
        lazygit)
            # Backup XDG config location if it exists
            if [ -e "$HOME/.config/lazygit" ] && [ ! -L "$HOME/.config/lazygit" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/lazygit" "$backup_dir/" || {
                    print_error "Failed to backup lazygit config"
                    return 1
                }
                print_warning "Backed up existing lazygit config (XDG) to: $backup_dir"
            fi
            # On macOS, also backup Library location if it exists
            if [ "$os" = "macos" ]; then
                if [ -e "$HOME/Library/Application Support/lazygit" ] && [ ! -L "$HOME/Library/Application Support/lazygit" ]; then
                    mkdir -p "$backup_dir" || {
                        print_error "Failed to create backup directory: $backup_dir"
                        return 1
                    }
                    mv "$HOME/Library/Application Support/lazygit" "$backup_dir/lazygit-macos" || {
                        print_error "Failed to backup lazygit config (macOS)"
                        return 1
                    }
                    print_warning "Backed up existing lazygit config (macOS) to: $backup_dir/lazygit-macos"
                fi
            fi
            ;;
        starship)
            if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/starship.toml" "$backup_dir/" || {
                    print_error "Failed to backup starship config"
                    return 1
                }
                print_warning "Backed up existing starship config to: $backup_dir"
            fi
            ;;
        tmux)
            if [ -e "$HOME/.config/tmux" ] && [ ! -L "$HOME/.config/tmux" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/tmux" "$backup_dir/" || {
                    print_error "Failed to backup tmux config"
                    return 1
                }
                print_warning "Backed up existing tmux config to: $backup_dir"
            fi
            ;;
        wezterm)
            if [ -e "$HOME/.config/wezterm" ] && [ ! -L "$HOME/.config/wezterm" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/wezterm" "$backup_dir/" || {
                    print_error "Failed to backup wezterm config"
                    return 1
                }
                print_warning "Backed up existing wezterm config to: $backup_dir"
            fi
            ;;
        zoxide)
            if [ -e "$HOME/.config/zoxide" ] && [ ! -L "$HOME/.config/zoxide" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                mv "$HOME/.config/zoxide" "$backup_dir/" || {
                    print_error "Failed to backup zoxide config"
                    return 1
                }
                print_warning "Backed up existing zoxide config to: $backup_dir"
            fi
            ;;
        zsh)
            if [ -e "$HOME/.config/zsh" ] && [ ! -L "$HOME/.config/zsh" ]; then
                mkdir -p "$backup_dir" || {
                    print_error "Failed to create backup directory: $backup_dir"
                    return 1
                }
                # Backup but preserve .zshrc.local if it exists
                if [ -f "$HOME/.config/zsh/.zshrc.local" ]; then
                    cp "$HOME/.config/zsh/.zshrc.local" "$backup_dir/.zshrc.local.keep" || {
                        print_warning "Failed to preserve .zshrc.local"
                    }
                fi
                mv "$HOME/.config/zsh" "$backup_dir/" || {
                    print_error "Failed to backup zsh config"
                    return 1
                }
                print_warning "Backed up existing zsh config to: $backup_dir"
            fi
            ;;
    esac

    return 0
}

install_package() {
    local package=$1

    # Special handling for binary-only packages
    if [ "$package" = "eza" ]; then
        setup_eza
        return 0
    elif [ "$package" = "fzf" ]; then
        setup_fzf
        return 0
    fi

    # Verify package directory exists
    if [ ! -d "$DOTFILES_DIR/$package" ]; then
        print_error "Package directory not found: $DOTFILES_DIR/$package"
        return 1
    fi

    if is_already_stowed "$package"; then
        print_info "$package is already stowed, skipping..."
        return 0
    fi

    print_info "Installing ${CYAN}$package${NC}..."

    # Backup existing config
    backup_existing "$package"

    # Stow the package
    cd "$DOTFILES_DIR" || {
        print_error "Failed to change to dotfiles directory"
        return 1
    }

    local stow_output
    if stow_output=$(stow "$package" 2>&1); then
        print_success "$package installed successfully"

        # Special handling for specific packages
        case "$package" in
            bash)
                setup_bash
                ;;
            bat)
                setup_bat
                ;;
            git)
                setup_git
                ;;
            tmux)
                setup_tmux
                ;;
            lazygit)
                setup_lazygit
                ;;
            zsh)
                setup_zsh
                ;;
            starship)
                setup_starship
                ;;
            zoxide)
                setup_zoxide
                ;;
        esac
        return 0
    else
        print_error "Failed to stow $package"
        print_error "Stow output: $stow_output"
        return 1
    fi
}