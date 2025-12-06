#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Supports both interactive and non-interactive modes
# Compatible with bash and zsh

set -e

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    NC=''
fi

# Script directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Available packages
AVAILABLE_PACKAGES=("git" "lazygit" "nvim" "starship" "tmux" "wezterm" "zsh")

# Functions
print_header() {
    echo ""
    echo -e "${MAGENTA}╔════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}     ${CYAN}Dotfiles Installation Script${NC}     ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════╝${NC}"
    echo ""
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

detect_shell() {
    local current_shell
    current_shell="$(basename "$SHELL")"
    print_info "Current shell: ${CYAN}$current_shell${NC}"
    echo "$current_shell"
}

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unix"
    fi
}

get_install_command() {
    local package=${1:-stow}
    local os=$(detect_os)

    if [ "$os" = "macos" ]; then
        echo "brew install $package"
    elif [ "$os" = "linux" ]; then
        if command -v apt &> /dev/null; then
            echo "sudo apt install $package"
        elif command -v pacman &> /dev/null; then
            echo "sudo pacman -S $package"
        elif command -v dnf &> /dev/null; then
            echo "sudo dnf install $package"
        elif command -v yum &> /dev/null; then
            echo "sudo yum install $package"
        else
            echo "Use your package manager to install: $package"
        fi
    else
        echo "Use your package manager to install: $package"
    fi
}

check_binary_installed() {
    local binary=$1
    command -v "$binary" &> /dev/null
}

install_binary() {
    local binary=$1
    local install_cmd=$(get_install_command "$binary")

    print_info "Installing $binary binary..."

    if [[ "$install_cmd" == *"Use your package manager"* ]]; then
        print_error "Could not determine package manager"
        print_info "Please install $binary manually and re-run this script"
        return 1
    fi

    print_info "Running: ${CYAN}$install_cmd${NC}"

    if eval "$install_cmd"; then
        print_success "$binary installed successfully"
        return 0
    else
        print_error "Failed to install $binary"
        return 1
    fi
}

check_dependencies() {
    print_info "Checking dependencies..."

    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed"
        local install_cmd=$(get_install_command "stow")
        print_info "Install it with: ${CYAN}$install_cmd${NC}"
        return 1
    fi

    print_success "GNU Stow is installed"
    return 0
}

is_already_stowed() {
    local package=$1
    local target_dir=""
    local source_dir=""
    local os=$(detect_os)

    case "$package" in
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
        zsh)
            target_dir="$HOME/.config/zsh"
            source_dir="$DOTFILES_DIR/zsh/.config/zsh"
            ;;
    esac

    # Check if it's a symlink pointing to our dotfiles
    if [ -L "$target_dir" ]; then
        local link_target
        # Get absolute path of symlink target
        link_target=$(readlink -f "$target_dir" 2>/dev/null)
        # Check if it points to our dotfiles directory
        if [[ "$link_target" == "$source_dir" ]]; then
            return 0  # Already correctly stowed
        fi
    fi

    # For lazygit on macOS, also check if config.yml is symlinked
    if [ "$package" = "lazygit" ] && [ "$os" = "macos" ]; then
        if [ -L "$HOME/Library/Application Support/lazygit/config.yml" ]; then
            local link_target
            link_target=$(readlink -f "$HOME/Library/Application Support/lazygit/config.yml" 2>/dev/null)
            if [[ "$link_target" == "$HOME/.config/lazygit/config.yml" ]]; then
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
            lazygit)
                setup_lazygit
                ;;
            zsh)
                setup_zsh
                ;;
            starship)
                setup_starship
                ;;
        esac
        return 0
    else
        print_error "Failed to stow $package"
        print_error "Stow output: $stow_output"
        return 1
    fi
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
            rc_file="$HOME/.bashrc"
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
            echo -e "  ${CYAN}eval \"\$(starship init $shell)\"${NC}"
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

interactive_mode() {
    local current_shell
    current_shell=$(detect_shell)

    echo ""
    print_info "Available packages to install:"
    echo ""

    for i in "${!AVAILABLE_PACKAGES[@]}"; do
        local pkg="${AVAILABLE_PACKAGES[$i]}"
        local status=""

        if is_already_stowed "$pkg"; then
            status="${GREEN}[installed]${NC}"
        else
            status="${YELLOW}[not installed]${NC}"
        fi

        echo -e "  $((i+1)). ${CYAN}$pkg${NC} $status"
    done

    echo ""
    echo -e "  ${CYAN}a${NC}. Install all"
    echo -e "  ${CYAN}q${NC}. Quit"
    echo ""

    # Special warning for zsh if not current shell
    if [ "$current_shell" != "zsh" ]; then
        print_warning "Your current shell is $current_shell. Installing zsh config won't change your default shell."
        print_info "To change your shell, run: ${CYAN}chsh -s \$(which zsh)${NC}"
        echo ""
    fi

    read -rp "$(echo -e "${BLUE}Select packages to install${NC} (e.g., 1 2 4, or a for all): ")" selection

    if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
        print_info "Installation cancelled"
        exit 0
    fi

    local packages_to_install=()

    if [ "$selection" = "a" ] || [ "$selection" = "A" ]; then
        packages_to_install=("${AVAILABLE_PACKAGES[@]}")
    else
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#AVAILABLE_PACKAGES[@]}" ]; then
                packages_to_install+=("${AVAILABLE_PACKAGES[$((num-1))]}")
            else
                print_warning "Invalid selection: $num"
            fi
        done
    fi

    if [ ${#packages_to_install[@]} -eq 0 ]; then
        print_error "No valid packages selected"
        exit 1
    fi

    echo ""
    print_info "Will install: ${CYAN}${packages_to_install[*]}${NC}"
    echo ""
    read -rp "$(echo -e "${BLUE}Continue?${NC} [Y/n]: ")" confirm

    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]; then
        print_info "Installation cancelled"
        exit 0
    fi

    echo ""
    for pkg in "${packages_to_install[@]}"; do
        install_package "$pkg"
    done
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [PACKAGES...]

Install dotfiles using GNU Stow.

OPTIONS:
    -h, --help          Show this help message
    -a, --all           Install all packages
    -i, --interactive   Interactive mode (default if no packages specified)

PACKAGES:
    ${AVAILABLE_PACKAGES[*]}

EXAMPLES:
    $0                  # Interactive mode
    $0 -i               # Interactive mode (explicit)
    $0 nvim zsh         # Install nvim and zsh
    $0 --all            # Install all packages

NOTES:
    - Existing configurations will be backed up to ~/.dotfiles_backup/
    - For zsh: ~/.zshenv and ~/.zshrc will be created automatically
    - Run 'exec zsh' after installing zsh to apply changes

EOF
}

main() {
    local install_all=0
    local interactive=0
    local packages_to_install=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                install_all=1
                shift
                ;;
            -i|--interactive)
                interactive=1
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                # Check if it's a valid package
                if [[ " ${AVAILABLE_PACKAGES[*]} " =~ " $1 " ]]; then
                    packages_to_install+=("$1")
                else
                    print_error "Unknown package: $1"
                    print_info "Available packages: ${AVAILABLE_PACKAGES[*]}"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    print_header

    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi

    echo ""

    # Determine mode
    if [ $interactive -eq 1 ] || [ ${#packages_to_install[@]} -eq 0 ] && [ $install_all -eq 0 ]; then
        interactive_mode
    else
        if [ $install_all -eq 1 ]; then
            packages_to_install=("${AVAILABLE_PACKAGES[@]}")
        fi

        detect_shell
        echo ""

        for pkg in "${packages_to_install[@]}"; do
            install_package "$pkg"
        done
    fi

    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Next steps:"
    echo -e "  - Review your configurations in ${CYAN}~/.config/${NC}"

    if [[ " ${packages_to_install[*]} " =~ " starship " ]]; then
        echo -e "  - Reload your shell to activate Starship prompt"
    fi

    if [[ " ${packages_to_install[*]} " =~ " zsh " ]]; then
        echo -e "  - Restart your terminal or run: ${CYAN}exec zsh${NC}"
        echo -e "  - Add machine-specific config to: ${CYAN}~/.config/zsh/.zshrc.local${NC}"
    fi
    echo ""
}

# Run main function
main "$@"
