#!/usr/bin/env bash

set_capsule() {
  local name="$1"
  local bg="${2:-$CAPSULE_BG}"
  local border="${3:-$CAPSULE_BORDER}"

  sketchybar --set "$name" \
    background.drawing=on \
    background.color="$bg" \
    background.border_color="$border" \
    background.border_width="$BORDER_WIDTH" \
    background.height="$ITEM_HEIGHT" \
    background.corner_radius="$CAPSULE_RADIUS"
}

set_soft_capsule() {
  local name="$1"
  set_capsule "$name" "$CAPSULE_BG_SOFT" "$CAPSULE_BORDER"
}

set_ghost_capsule() {
  local name="$1"
  set_capsule "$name" "$CAPSULE_BG_GHOST" "0x20d3c6aa"
}
