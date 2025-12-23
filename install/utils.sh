#!/usr/bin/env bash

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

# Cross-platform readlink -f equivalent
# BSD readlink (macOS) doesn't support -f, so we need a fallback
get_absolute_path() {
    local path="$1"

    # Try greadlink first (from coreutils on macOS)
    if command -v greadlink &> /dev/null; then
        local result
        result=$(greadlink -f "$path" 2>/dev/null)
        if [ -n "$result" ]; then
            echo "$result"
            return
        fi
    fi

    # Try readlink -f (works on Linux)
    local result
    result=$(readlink -f "$path" 2>/dev/null)
    if [ -n "$result" ]; then
        echo "$result"
        return
    fi

    # Fallback for BSD readlink (macOS)
    if [ -L "$path" ]; then
        local target
        target=$(readlink "$path" 2>/dev/null)
        if [ -n "$target" ]; then
            # If target is relative, make it absolute
            if [[ "$target" != /* ]]; then
                local dir
                dir=$(dirname "$path")
                target="$dir/$target"
            fi
            # Resolve the absolute path
            local dir_path base_name
            dir_path=$(cd "$(dirname "$target")" 2>/dev/null && pwd -P)
            base_name=$(basename "$target")
            echo "$dir_path/$base_name"
        fi
    elif [ -e "$path" ]; then
        # Not a symlink, just resolve to absolute path
        local dir_path base_name
        dir_path=$(cd "$(dirname "$path")" 2>/dev/null && pwd -P)
        base_name=$(basename "$path")
        echo "$dir_path/$base_name"
    fi
}

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
        if command -v brew &> /dev/null; then
            echo "brew install $package"
        elif command -v apt &> /dev/null; then
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
