#!/usr/bin/env bash
#
# Dotfiles Installation Script
# Supports both interactive and non-interactive modes
# Runs in bash but detects and configures user's shell (bash/zsh/fish)

set -e

# Script directory
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source modules
source "$DOTFILES_DIR/install/utils.sh"
source "$DOTFILES_DIR/install/setup.sh"
source "$DOTFILES_DIR/install/packages.sh"
source "$DOTFILES_DIR/install/interactive.sh"

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
        # Get installed packages from interactive mode
        if [ -n "$INSTALLED_PACKAGES" ]; then
            IFS=' ' read -r -a packages_to_install <<< "$INSTALLED_PACKAGES"
        fi
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

    # Determine if we should offer to reload the shell
    local should_reload=0
    local reload_shell=""

    if [[ " ${packages_to_install[*]} " =~ " bash " ]] || [[ " ${packages_to_install[*]} " =~ " zsh " ]] || \
       [[ " ${packages_to_install[*]} " =~ " starship " ]] || [[ " ${packages_to_install[*]} " =~ " zoxide " ]] || \
       [[ " ${packages_to_install[*]} " =~ " bat " ]]; then
        should_reload=1
        # Use current shell
        reload_shell="$(basename "$SHELL")"
    fi

    if [[ " ${packages_to_install[*]} " =~ " zsh " ]]; then
        echo -e "  - Add machine-specific config to: ${CYAN}~/.config/zsh/.zshrc.local${NC}"
    fi

    if [[ " ${packages_to_install[*]} " =~ " bash " ]]; then
        echo -e "  - Add machine-specific config to: ${CYAN}~/.bashrc.local${NC}"
    fi

    echo ""

    # Offer to reload shell immediately
    if [ $should_reload -eq 1 ]; then
        echo -e "${BLUE}Shell configuration has been updated.${NC}"
        read -rp "$(echo -e "Would you like to reload your shell now to apply changes? [Y/n]: ")" reload_confirm

        if [ "$reload_confirm" != "n" ] && [ "$reload_confirm" != "N" ]; then
            print_info "Reloading shell..."
            echo ""
            exec "$SHELL"
        else
            print_info "Remember to reload your shell later with: ${CYAN}exec $reload_shell${NC}"
            echo ""
        fi
    fi
}

# Run main function
main "$@"