#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

app="${INFO:-}"

if [ -z "$app" ]; then
  app="$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null || true)"
fi

app="${app:-App}"

case "$app" in
  Ghostty)
    icon="$ICON_APP_TERMINAL"
    color="$GREEN"
    ;;
  "Brave Browser"|Brave)
    icon="$ICON_APP_BROWSER"
    color="$BLUE"
    ;;
  "Codex"*|codex*|Codex)
    icon="$ICON_APP_AI"
    color="$PURPLE"
    ;;
  Preview)
    icon="$ICON_APP_READING"
    color="$YELLOW"
    ;;
  Finder)
    icon="$ICON_APP_FINDER"
    color="$AQUA"
    ;;
  Zed)
    icon="$ICON_APP_ZED"
    color="$GREEN"
    ;;
  *)
    icon="$ICON_APP_DEFAULT"
    color="$FG"
    ;;
esac

sketchybar --animate tanh 8 \
  --set "$NAME" \
    icon="$icon" \
    label="$app" \
    icon.color="$color" \
    background.border_color="0x307fbbb3"
