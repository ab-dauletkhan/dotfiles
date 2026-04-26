#!/bin/bash

PERCENT="$(pmset -g batt | grep -Eo '[0-9]+%' | head -n 1)"
SOURCE="$(pmset -g batt | head -n 1)"

if echo "$SOURCE" | grep -q "AC Power"; then
  ICON="󰂄"
else
  ICON="󰁹"
fi

sketchybar --set "$NAME" icon="$ICON" label="$PERCENT"
