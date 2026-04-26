#!/bin/bash

VOL="${INFO:-$(osascript -e 'output volume of (get volume settings)')}"

if [ "$VOL" = "0" ]; then
  ICON="󰝟"
else
  ICON=""
fi

sketchybar --set "$NAME" icon="$ICON" label="$VOL%"
