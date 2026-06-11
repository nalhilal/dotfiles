#!/usr/bin/env bash
# Regenerate starship.light.toml from starship.toml after editing module config.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/.config"

cp "$CONFIG_DIR/starship.toml" "$CONFIG_DIR/starship.light.toml"

if [[ "$(uname -s)" == "Darwin" ]]; then
    sed -i '' "s/palette = 'synthwave_2077'/palette = 'synthwave_2077_light'/" "$CONFIG_DIR/starship.light.toml"
else
    sed -i "s/palette = 'synthwave_2077'/palette = 'synthwave_2077_light'/" "$CONFIG_DIR/starship.light.toml"
fi

echo "Updated $CONFIG_DIR/starship.light.toml"
