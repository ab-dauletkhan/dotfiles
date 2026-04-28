#!/usr/bin/env bash

export CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
export ITEM_DIR="$CONFIG_DIR/items"
export PLUGIN_DIR="$CONFIG_DIR/plugins"

# Fonts
export FONT="Monaspace Krypton Var:Medium:13.0"
export FONT_BOLD="Monaspace Krypton Var:Bold:13.0"
export ICON_FONT="Symbols Nerd Font Mono:Regular:15.0"

# Sizes
export BAR_HEIGHT=36
export ITEM_HEIGHT=26
export CAPSULE_RADIUS=13
export BORDER_WIDTH=1

# Spacing
export ITEM_PADDING_LEFT=4
export ITEM_PADDING_RIGHT=4
export ICON_PADDING_LEFT=9
export ICON_PADDING_RIGHT=5
export LABEL_PADDING_LEFT=0
export LABEL_PADDING_RIGHT=9

# Battery
# 0 = compact: 78%
# 1 = detailed: 78% 31° 28×
export SHOW_BATTERY_DETAILS=0
