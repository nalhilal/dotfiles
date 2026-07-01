# Starship prompt initialization with light/dark config selection
starship_resolve_config() {
    local config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
    local dark_config="$config_dir/starship.toml"
    local light_config="$config_dir/starship.light.toml"

    if [[ -n "${STARSHIP_CONFIG:-}" && "$STARSHIP_CONFIG" != "$dark_config" && "$STARSHIP_CONFIG" != "$light_config" ]]; then
        return 0
    fi

    local appearance="dark"

    if [[ -n "${STARSHIP_APPEARANCE:-}" ]]; then
        appearance="$STARSHIP_APPEARANCE"
    elif [[ -n "${WEZTERM_EXECUTABLE:-}" || -n "${WEZTERM_PANE:-}" ]]; then
        appearance="dark"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        if ! defaults read -g AppleInterfaceStyle &>/dev/null; then
            appearance="light"
        fi
    elif command -v gsettings &>/dev/null; then
        local color_scheme gtk_theme
        color_scheme="$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)"
        gtk_theme="$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)"

        if [[ "$color_scheme" == *prefer-light* ]]; then
            appearance="light"
        elif [[ "$color_scheme" == *prefer-dark* || "$gtk_theme" == *-dark* || "$gtk_theme" == *-Dark* ]]; then
            appearance="dark"
        elif [[ -n "$color_scheme$gtk_theme" ]]; then
            appearance="light"
        fi
    elif [[ -n "${COLORFGBG:-}" ]]; then
        local bg="${COLORFGBG##*;}"
        if [[ "$bg" == "15" || "$bg" =~ ^[7-9]$ ]]; then
            appearance="light"
        fi
    fi

    if [[ "$appearance" == "light" ]] && [[ -f "$light_config" ]]; then
        export STARSHIP_CONFIG="$light_config"
    else
        export STARSHIP_CONFIG="$dark_config"
    fi
}

if command -v starship &> /dev/null; then
    starship_resolve_config
    eval "$(starship init zsh)"
fi
