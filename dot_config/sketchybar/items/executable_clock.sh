#!/usr/bin/env bash

sketchybar --add item clock right \
  --set clock \
    icon="$ICON_CLOCK" \
    label="--:--" \
    update_freq=30 \
    script="$PLUGIN_DIR/clock.sh"

set_soft_capsule clock
