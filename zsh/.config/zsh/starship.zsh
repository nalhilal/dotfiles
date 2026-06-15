# Starship prompt initialization with light/dark config selection
starship_resolve_config() {
    if [[ -n "${STARSHIP_CONFIG:-}" ]]; then
        return 0
    fi

    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    local appearance="dark"

    if [[ -n "${STARSHIP_APPEARANCE:-}" ]]; then
        appearance="$STARSHIP_APPEARANCE"
    elif [[ -n "${WEZTERM_EXECUTABLE:-}" || -n "${WEZTERM_PANE:-}" ]]; then
        appearance="dark"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        if ! defaults read -g AppleInterfaceStyle &>/dev/null; then
            appearance="light"
        fi
    elif [[ -n "${COLORFGBG:-}" ]]; then
        local bg="${COLORFGBG##*;}"
        if [[ "$bg" == "15" || "$bg" =~ ^[7-9]$ ]]; then
            appearance="light"
        fi
    fi

    if [[ "$appearance" == "light" ]] && [[ -f "$config_dir/starship.light.toml" ]]; then
        export STARSHIP_CONFIG="$config_dir/starship.light.toml"
    else
        export STARSHIP_CONFIG="$config_dir/starship.toml"
    fi
}

if command -v starship &> /dev/null; then
    starship_resolve_config
    eval "$(starship init zsh)"
fi
