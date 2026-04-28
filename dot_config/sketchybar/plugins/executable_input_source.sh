#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

state_file="${TMPDIR:-/tmp}/sketchybar_input_source_last"

source_id="$(
  /usr/bin/defaults read "$HOME/Library/Preferences/com.apple.HIToolbox.plist" AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null \
  || /usr/bin/defaults read com.apple.HIToolbox AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null \
  || true
)"

case "$source_id" in
  *ABC*|*US*|*U.S.*|*English*)
    lang="EN"
    color="$BLUE"
    ;;
  *Kazakh*|*Kazakhstan*|*KZ*|*Qazaq*|*Qazaqsha*)
    lang="KZ"
    color="$YELLOW"
    ;;
  *)
    lang="??"
    color="$RED"
    ;;
esac

previous_lang="$(cat "$state_file" 2>/dev/null || true)"

# First run or same language: update silently, no spin.
if [ -z "$previous_lang" ] || [ "$previous_lang" = "$lang" ]; then
  printf "%s" "$lang" > "$state_file"

  sketchybar --set "$NAME" \
    icon="$ICON_INPUT" \
    label="$lang" \
    label.color="$color" \
    icon.color="$color" \
    background.border_color="$color" \
    label.y_offset=0 \
    icon.y_offset=0

  exit 0
fi

printf "%s" "$lang" > "$state_file"

# Fast slot-machine style switch.
sketchybar --animate tanh 5 \
  --set "$NAME" \
    label.y_offset=-9 \
    icon.y_offset=-9 \
    background.border_color="$color"

sleep 0.055

sketchybar --set "$NAME" \
  label="$lang" \
  label.y_offset=9 \
  icon.y_offset=9 \
  label.color="$color" \
  icon.color="$color"

sketchybar --animate tanh 6 \
  --set "$NAME" \
    label.y_offset=0 \
    icon.y_offset=0
