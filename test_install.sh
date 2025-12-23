#!/usr/bin/env bash
#
# Test suite for install.sh
# Tests the actual installer in a safe temporary environment

set -e
set -o pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Locations
ORIG_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR=""
MOCK_HOME=""
MOCK_DOTFILES=""

# Setup test environment
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    MOCK_HOME="$TEST_DIR/home"
    MOCK_DOTFILES="$TEST_DIR/dotfiles" # Use 'dotfiles' directory to simulate repo root

    mkdir -p "$MOCK_HOME"
    mkdir -p "$MOCK_HOME/.config"
    mkdir -p "$MOCK_DOTFILES"

    # Copy installer scripts to mock dotfiles
    cp "$ORIG_DOTFILES_DIR/install.sh" "$MOCK_DOTFILES/"
    cp -r "$ORIG_DOTFILES_DIR/install" "$MOCK_DOTFILES/"

    # Create macOS Library structure if on macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mkdir -p "$MOCK_HOME/Library/Application Support"
    fi

    # Create mock dotfiles content
    mkdir -p "$MOCK_DOTFILES/nvim/.config/nvim"
    mkdir -p "$MOCK_DOTFILES/lazygit/.config/lazygit"
    mkdir -p "$MOCK_DOTFILES/starship/.config"
    mkdir -p "$MOCK_DOTFILES/tmux/.config/tmux/plugins/tpm"
    mkdir -p "$MOCK_DOTFILES/wezterm/.config/wezterm"
    mkdir -p "$MOCK_DOTFILES/zoxide/.config/zoxide"
    mkdir -p "$MOCK_DOTFILES/zsh/.config/zsh"
    mkdir -p "$MOCK_DOTFILES/bash/.config/bash"
    mkdir -p "$MOCK_DOTFILES/git/.config/git"

    echo "mock nvim config" > "$MOCK_DOTFILES/nvim/.config/nvim/init.lua"
    echo "mock lazygit config" > "$MOCK_DOTFILES/lazygit/.config/lazygit/config.yml"
    echo "mock starship config" > "$MOCK_DOTFILES/starship/.config/starship.toml"
    echo "mock tmux config" > "$MOCK_DOTFILES/tmux/.config/tmux/tmux.conf"
    echo "#!/usr/bin/env bash" > "$MOCK_DOTFILES/tmux/.config/tmux/plugins/tpm/tpm"
    chmod +x "$MOCK_DOTFILES/tmux/.config/tmux/plugins/tpm/tpm"
    echo "mock wezterm config" > "$MOCK_DOTFILES/wezterm/.config/wezterm/wezterm.lua"
    echo "mock zoxide config" > "$MOCK_DOTFILES/zoxide/.config/zoxide/README.md"
    echo "mock zsh config" > "$MOCK_DOTFILES/zsh/.config/zsh/.zshrc"
    echo "mock zsh env" > "$MOCK_DOTFILES/zsh/.config/zsh/.zshenv"
    echo "*.local" > "$MOCK_DOTFILES/zsh/.config/zsh/.gitignore"
    echo "mock bashrc" > "$MOCK_DOTFILES/bash/.config/bash/bashrc"
    echo "mock bash_profile" > "$MOCK_DOTFILES/bash/.config/bash/bash_profile"

    # Create mock stow command
    cat > "$TEST_DIR/stow" << 'EOF'
#!/usr/bin/env bash
# Mock stow command for testing
# Usage: stow package
# Since we run in DOTFILES_DIR, stow defaults to stowing into parent dir (TEST_DIR).
# But we want to stow into MOCK_HOME.
# The real stow would be run as: stow -t $HOME package (if we used -t)
# OR we rely on stow's default behavior of ../
# In our mock structure:
# TEST_DIR/
#   dotfiles/ (cwd)
#   home/     (target?)
# Stow default target is .., which is TEST_DIR.
# But we want it to go to MOCK_HOME.
#
# To simplify testing without changing install.sh (which assumes stow works relative or is configured),
# We will make this mock stow behave 'intelligently' based on the environment variables
# or just implement the logic we expect install.sh to achieve.

package=$1
dotfiles_dir=$(pwd)

# Verify we are in the dotfiles dir
if [[ "$dotfiles_dir" != *"dotfiles" ]]; then
    echo "stow: not in dotfiles directory"
    exit 1
fi

# Use the mocked HOME as target
target_dir="$HOME"

case "$package" in
    nvim)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/nvim/.config/nvim" "$target_dir/.config/nvim"
        ;;
    lazygit)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/lazygit/.config/lazygit" "$target_dir/.config/lazygit"
        ;;
    starship)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/starship/.config/starship.toml" "$target_dir/.config/starship.toml"
        ;;
    tmux)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/tmux/.config/tmux" "$target_dir/.config/tmux"
        ;;
    wezterm)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/wezterm/.config/wezterm" "$target_dir/.config/wezterm"
        ;;
    zoxide)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/zoxide/.config/zoxide" "$target_dir/.config/zoxide"
        ;;
    zsh)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/zsh/.config/zsh" "$target_dir/.config/zsh"
        ;;
    bash)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/bash/.config/bash" "$target_dir/.config/bash"
        ;;
    git)
        mkdir -p "$target_dir/.config"
        ln -sf "$dotfiles_dir/git/.config/git" "$target_dir/.config/git"
        ;;
esac
echo "stow: simulating stow $package"
EOF
    chmod +x "$TEST_DIR/stow"

    # Create mock git command
    cat > "$TEST_DIR/git" << 'EOF'
#!/usr/bin/env bash
if [ "$1" = "submodule" ] && [ "$2" = "update" ]; then
    echo "Submodule path 'tmux/.config/tmux/plugins/tpm': cloned"
    exit 0
fi
exec /usr/bin/git "$@"
EOF
    chmod +x "$TEST_DIR/git"

    # Create mock starship
    touch "$TEST_DIR/starship"
    chmod +x "$TEST_DIR/starship"

    # Create mock zoxide
    touch "$TEST_DIR/zoxide"
    chmod +x "$TEST_DIR/zoxide"

    echo -e "${CYAN}Test environment created at: $TEST_DIR${NC}"
}

cleanup_test_env() {
    if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        echo -e "${CYAN}Test environment cleaned up${NC}"
    fi
}

# Test functions
print_test() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}TEST $((TESTS_RUN + 1)): $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    TESTS_RUN=$((TESTS_RUN + 1))
}

assert_true() {
    local condition=$1
    local message=$2

    if [ "$condition" = "true" ] || [ "$condition" = "0" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    ${RED}Expected: true, Got: $condition${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_exists() {
    local file=$1
    local message=${2:-"File $file should exist"}

    if [ -e "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    ${RED}File not found: $file${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_file_not_exists() {
    local file=$1
    local message=${2:-"File $file should not exist"}

    if [ ! -e "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    ${RED}File exists: $file${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

assert_symlink() {
    local file=$1
    local message=${2:-"$file should be a symlink"}

    if [ -L "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo -e "  ${RED}✗${NC} $message"
        echo -e "    ${RED}Not a symlink: $file${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

run_install_script() {
    # Set environment variables for the run
    export HOME="$MOCK_HOME"
    export PATH="$TEST_DIR:$PATH"
    
    # Run the script from the mock dotfiles directory
    # Capturing output to avoid clutter, unless error
    "$MOCK_DOTFILES/install.sh" "$@" >> "$TEST_DIR/install.log" 2>&1
    local status=$?
    
    if [ $status -ne 0 ]; then
        echo -e "${RED}Install script failed with status $status${NC}"
        echo -e "${RED}Output:${NC}"
        cat "$TEST_DIR/install.log"
    fi
    
    return $status
}

# Test 1: Install single package (nvim)
test_install_single_package() {
    print_test "Install Single Package (nvim)"
    
    # Run install.sh
    if run_install_script "nvim"; then
        assert_true "0" "Install script execution successful"
    else
        assert_true "1" "Install script execution failed"
        return
    fi

    assert_file_exists "$MOCK_HOME/.config/nvim" "Should create nvim config directory"
    assert_symlink "$MOCK_HOME/.config/nvim" "Should create symlink to nvim dir"
    assert_file_exists "$MOCK_HOME/.config/nvim/init.lua" "init.lua should be accessible"
}

# Test 2: Backup existing functionality
test_backup_existing() {
    print_test "Backup Existing Configurations"

    # Create existing config
    mkdir -p "$MOCK_HOME/.config/tmux"
    echo "existing config" > "$MOCK_HOME/.config/tmux/tmux.conf"

    # Run install.sh
    run_install_script "tmux"

    # Check backup
    # Find the backup directory (it has a timestamp)
    local backup_dir
    backup_dir=$(find "$MOCK_HOME/.dotfiles_backup" -type d -name "20*" | head -n 1)

    if [ -n "$backup_dir" ]; then
        assert_true "0" "Backup directory created: $backup_dir"
        assert_file_exists "$backup_dir/tmux/tmux.conf" "Should backup existing config"
    else
        assert_true "1" "Backup directory not found"
    fi
    
    assert_symlink "$MOCK_HOME/.config/tmux" "New config directory should be stowed"
    assert_file_exists "$MOCK_HOME/.config/tmux/tmux.conf" "tmux.conf should be accessible"
}

# Test 3: Zsh setup (creates files)
test_zsh_setup() {
    print_test "Zsh Setup"

    # Run install.sh
    run_install_script "zsh"

    assert_symlink "$MOCK_HOME/.config/zsh" "Should symlink zsh config dir"
    assert_file_exists "$MOCK_HOME/.config/zsh/.zshrc" "Should have .zshrc in config dir"
    assert_file_exists "$MOCK_HOME/.zshenv" "Should create ~/.zshenv"
    assert_file_exists "$MOCK_HOME/.zshrc" "Should create placeholder ~/.zshrc"
    assert_file_exists "$MOCK_HOME/.config/zsh/.zshrc.local" "Should create .zshrc.local"
}

# Test 4: Bash setup
test_bash_setup() {
    print_test "Bash Setup"
    
    run_install_script "bash"
    
    assert_file_exists "$MOCK_HOME/.bashrc" "Should create .bashrc"
    
    if grep -q "source.*\.config/bash/bashrc" "$MOCK_HOME/.bashrc"; then
        assert_true "0" ".bashrc should source dotfiles bashrc"
    else
        assert_true "1" ".bashrc missing source command"
    fi
}

# Test 5: Re-running installation (idempotency/skip)
test_rerun() {
    print_test "Idempotency (Re-run)"
    
    # Run nvim installation again (it was installed in test 1, but we share env?
    # Actually wait, if we share env, nvim IS installed.
    # The previous tests modified the env.
    
    # Note: run_install_script doesn't clear env.
    
    run_install_script "nvim"
    
    # It should succeed and say "already stowed" in log
    if grep -q "already stowed" "$TEST_DIR/install.log"; then
        assert_true "0" "Should detect already stowed package"
    else
        # cat "$TEST_DIR/install.log"
        assert_true "1" "Should have skipped installation (check log)"
    fi
}

# Test 6: Invalid package
test_invalid_package() {
    print_test "Invalid Package"
    
    set +e
    run_install_script "invalid-package"
    local status=$?
    set -e
    
    if [ $status -ne 0 ]; then
        assert_true "0" "Should fail with invalid package"
    else
        assert_true "1" "Should fail with invalid package"
    fi
}

main() {
    set +e
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   Install Script Test Suite (E2E)    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""

    setup_test_env

    test_install_single_package
    test_backup_existing
    test_zsh_setup
    test_bash_setup
    test_rerun
    test_invalid_package

    echo ""
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        cleanup_test_env
        exit 0
    else
        echo -e "${RED}✗ Some tests failed!${NC}"
        # cleanup_test_env # Keep env for inspection on failure?
        exit 1
    fi
}

main