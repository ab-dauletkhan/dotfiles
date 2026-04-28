#!/usr/bin/env bash

sketchybar --add event input_source_change AppleSelectedInputSourcesChangedNotification

sketchybar --add item input_source right \
  --set input_source \
    icon="$ICON_INPUT" \
    label="EN" \
    label.font="$FONT_BOLD" \
    label.width=24 \
    label.align=center \
    script="$PLUGIN_DIR/input_source.sh" \
  --subscribe input_source input_source_change system_woke

set_capsule input_source "$CAPSULE_BG_SOFT" "$BLUE"
