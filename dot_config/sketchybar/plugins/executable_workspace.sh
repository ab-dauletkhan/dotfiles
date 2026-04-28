#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

state_file="${TMPDIR:-/tmp}/sketchybar_flashspace_workspace"

workspace="${WORKSPACE:-}"

if [ -z "$workspace" ]; then
  workspace="$(cat "$state_file" 2>/dev/null || true)"
fi

workspace="${workspace:-Terminal}"

case "$workspace" in
  Terminal)
    icon="$ICON_WS_TERMINAL"
    color="$GREEN"
    ;;
  Browser)
    icon="$ICON_WS_BROWSER"
    color="$BLUE"
    ;;
  AI|Ai|Al)
    workspace="AI"
    icon="$ICON_WS_AI"
    color="$PURPLE"
    ;;
  Reading)
    icon="$ICON_WS_READING"
    color="$YELLOW"
    ;;
  Others)
    icon="$ICON_WS_OTHERS"
    color="$GREY"
    ;;
  *)
    icon="$ICON_WS_DEFAULT"
    color="$FG"
    ;;
esac

printf "%s" "$workspace" > "$state_file"

sketchybar --animate tanh 10 \
  --set "$NAME" \
    icon="$icon" \
    label="$workspace" \
    icon.color="$color" \
    background.border_color="$color"
