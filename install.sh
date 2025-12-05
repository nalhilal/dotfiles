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
AVAILABLE_PACKAGES=("nvim" "starship" "wezterm" "zsh")

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

check_dependencies() {
    print_info "Checking dependencies..."

    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed"
        print_info "Install it with: ${CYAN}brew install stow${NC}"
        return 1
    fi

    print_success "GNU Stow is installed"
    return 0
}

is_already_stowed() {
    local package=$1
    local target_dir=""

    case "$package" in
        nvim)
            target_dir="$HOME/.config/nvim"
            ;;
        starship)
            target_dir="$HOME/.config/starship.toml"
            ;;
        wezterm)
            target_dir="$HOME/.config/wezterm"
            ;;
        zsh)
            target_dir="$HOME/.config/zsh"
            ;;
    esac

    if [ -L "$target_dir" ]; then
        return 0  # Already a symlink
    fi
    return 1
}

backup_existing() {
    local package=$1
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"
    local backed_up=0

    case "$package" in
        nvim)
            if [ -e "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
                mkdir -p "$backup_dir"
                mv "$HOME/.config/nvim" "$backup_dir/"
                print_warning "Backed up existing nvim config to: $backup_dir"
                backed_up=1
            fi
            ;;
        starship)
            if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
                mkdir -p "$backup_dir"
                mv "$HOME/.config/starship.toml" "$backup_dir/"
                print_warning "Backed up existing starship config to: $backup_dir"
                backed_up=1
            fi
            ;;
        wezterm)
            if [ -e "$HOME/.config/wezterm" ] && [ ! -L "$HOME/.config/wezterm" ]; then
                mkdir -p "$backup_dir"
                mv "$HOME/.config/wezterm" "$backup_dir/"
                print_warning "Backed up existing wezterm config to: $backup_dir"
                backed_up=1
            fi
            ;;
        zsh)
            if [ -e "$HOME/.config/zsh" ] && [ ! -L "$HOME/.config/zsh" ]; then
                mkdir -p "$backup_dir"
                # Backup but preserve .zshrc.local if it exists
                if [ -f "$HOME/.config/zsh/.zshrc.local" ]; then
                    cp "$HOME/.config/zsh/.zshrc.local" "$backup_dir/.zshrc.local.keep"
                fi
                mv "$HOME/.config/zsh" "$backup_dir/"
                print_warning "Backed up existing zsh config to: $backup_dir"
                backed_up=1
            fi
            ;;
    esac

    return $backed_up
}

install_package() {
    local package=$1

    if is_already_stowed "$package"; then
        print_info "$package is already stowed, skipping..."
        return 0
    fi

    print_info "Installing ${CYAN}$package${NC}..."

    # Backup existing config
    backup_existing "$package"

    # Stow the package
    cd "$DOTFILES_DIR"
    if stow "$package" 2>&1; then
        print_success "$package installed successfully"

        # Special handling for zsh
        if [ "$package" = "zsh" ]; then
            setup_zsh
        fi
    else
        print_error "Failed to stow $package"
        return 1
    fi
}

setup_zsh() {
    print_info "Setting up zsh configuration..."

    # Create ~/.zshenv if it doesn't exist
    if [ ! -f "$HOME/.zshenv" ]; then
        cat > "$HOME/.zshenv" << 'EOF'
# Set XDG-compliant zsh config directory
export ZDOTDIR="$HOME/.config/zsh"
EOF
        print_success "Created ~/.zshenv"
    else
        print_warning "~/.zshenv already exists, skipping..."
    fi

    # Create placeholder ~/.zshrc for installers
    if [ ! -f "$HOME/.zshrc" ]; then
        cat > "$HOME/.zshrc" << 'EOF'
# This file exists for installers that try to modify ~/.zshrc
# Zsh ignores this file because ZDOTDIR is set in ~/.zshenv
#
# If an installer adds something here, manually move it to:
# ~/.config/zsh/.zshrc.local (for machine-specific config)
#
# DO NOT source anything from here, as it would defeat the purpose of ZDOTDIR
EOF
        print_success "Created placeholder ~/.zshrc"
    else
        print_warning "~/.zshrc already exists, skipping..."
    fi

    # Create .zshrc.local if it doesn't exist
    if [ ! -f "$HOME/.config/zsh/.zshrc.local" ]; then
        cat > "$HOME/.config/zsh/.zshrc.local" << 'EOF'
# Machine-specific Zsh Configuration
# This file is NOT version controlled
# Add your machine-specific configurations here
#
# Examples:
# - PATH modifications for local tools
# - API keys and tokens
# - Tool initializations (conda, nvm, etc.)
EOF
        print_success "Created ~/.config/zsh/.zshrc.local"
    else
        print_info ".zshrc.local already exists, preserving..."
    fi

    # Manually symlink .gitignore if stow didn't (it sometimes skips it)
    if [ ! -e "$HOME/.config/zsh/.gitignore" ]; then
        ln -s "$DOTFILES_DIR/zsh/.config/zsh/.gitignore" "$HOME/.config/zsh/.gitignore"
        print_success "Symlinked .gitignore"
    fi

    print_success "Zsh setup complete!"
    print_info "Run ${CYAN}exec zsh${NC} or ${CYAN}source ~/.zshenv${NC} to apply changes"
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
    echo "  - Review your configurations in ${CYAN}~/.config/${NC}"
    if [[ " ${packages_to_install[*]} " =~ " zsh " ]]; then
        echo "  - Restart your terminal or run: ${CYAN}exec zsh${NC}"
        echo "  - Add machine-specific config to: ${CYAN}~/.config/zsh/.zshrc.local${NC}"
    fi
    echo ""
}

# Run main function
main "$@"
