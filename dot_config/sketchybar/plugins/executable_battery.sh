#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"
source "$CONFIG_DIR/settings.sh"

batt="$(pmset -g batt 2>/dev/null)"
percent="$(echo "$batt" | grep -Eo "[0-9]+%" | head -n1 | tr -d "%")"
percent="${percent:-0}"

smart="$(ioreg -r -c AppleSmartBattery -d 1 2>/dev/null)"

cycle="$(echo "$smart" | awk -F" = " '$1 ~ /"CycleCount"/ { gsub(/[^0-9]/, "", $2); print $2; exit }')"
cycle="${cycle:-?}"

temp_raw="$(echo "$smart" | awk -F" = " '$1 ~ /"Temperature"/ { gsub(/[^0-9]/, "", $2); print $2; exit }')"

if [ -n "$temp_raw" ] && [ "$temp_raw" != "0" ]; then
  temp="$(awk "BEGIN {printf \"%.0f\", $temp_raw / 100}")"
else
  temp="?"
fi

if echo "$batt" | grep -qi "AC Power"; then
  on_ac=1
else
  on_ac=0
fi

if echo "$batt" | grep -qi "not charging"; then
  hold=1
else
  hold=0
fi

if [ "$on_ac" = 1 ] && [ "$hold" = 1 ]; then
  icon="$ICON_BATTERY_HOLD"
  color="$AQUA"
elif [ "$on_ac" = 1 ]; then
  icon="$ICON_BATTERY_CHARGING"
  color="$GREEN"
elif [ "$percent" -le 15 ]; then
  icon="$ICON_BATTERY_LOW"
  color="$RED"
elif [ "$percent" -le 30 ]; then
  icon="$ICON_BATTERY_30"
  color="$YELLOW"
elif [ "$percent" -le 50 ]; then
  icon="$ICON_BATTERY_50"
  color="$YELLOW"
elif [ "$percent" -le 80 ]; then
  icon="$ICON_BATTERY_80"
  color="$GREEN"
else
  icon="$ICON_BATTERY_FULL"
  color="$GREEN"
fi

if [ "${SHOW_BATTERY_DETAILS:-0}" = "1" ]; then
  label="${percent}% ${temp}° ${cycle}×"
else
  label="${percent}%"
fi

sketchybar --animate tanh 8 \
  --set "$NAME" \
    icon="$icon" \
    label="$label" \
    icon.color="$color" \
    background.border_color="$color"
