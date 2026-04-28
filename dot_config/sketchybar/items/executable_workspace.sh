#!/usr/bin/env bash

sketchybar --add event flashspace_workspace_change

sketchybar --add item workspace left \
  --set workspace \
    icon="$ICON_WS_TERMINAL" \
    label="Terminal" \
    script="$PLUGIN_DIR/workspace.sh" \
  --subscribe workspace flashspace_workspace_change system_woke

set_capsule workspace "$CAPSULE_BG" "$GREEN"
