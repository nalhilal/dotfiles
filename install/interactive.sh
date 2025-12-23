#!/usr/bin/env bash

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
