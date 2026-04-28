#!/usr/bin/env bash

sketchybar --add item battery right \
  --set battery \
    icon="$ICON_BATTERY_FULL" \
    label="--%" \
    update_freq=30 \
    script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery power_source_change system_woke

set_capsule battery "$CAPSULE_BG_SOFT" "$GREEN"
