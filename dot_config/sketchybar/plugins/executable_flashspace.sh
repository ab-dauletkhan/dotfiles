#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TARGET_WORKSPACE_NUMBER="$1"

if [ "$TARGET_WORKSPACE_NUMBER" = "$WORKSPACE_NUMBER" ]; then
  sketchybar --set "$NAME" \
    background.color="$ACTIVE_BG" \
    icon.color="$BAR_BG" \
    label.color="$BAR_BG"
else
  sketchybar --set "$NAME" \
    background.color="$ITEM_BG" \
    icon.color="$FG" \
    label.color="$FG"
fi
