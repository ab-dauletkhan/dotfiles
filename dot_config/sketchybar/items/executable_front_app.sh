#!/usr/bin/env bash

sketchybar --add item front_app left \
  --set front_app \
    icon="$ICON_APP_DEFAULT" \
    label="App" \
    label.max_chars=22 \
    script="$PLUGIN_DIR/front_app.sh" \
  --subscribe front_app front_app_switched system_woke

set_ghost_capsule front_app
