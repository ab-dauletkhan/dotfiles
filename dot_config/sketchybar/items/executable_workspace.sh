#!/usr/bin/env bash

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

sketchybar --add event omniwm_workspace_change

ws_numbers=""
if command -v omniwmctl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
  ws_json=$(omniwmctl query workspaces --format json 2>/dev/null || true)
  if printf '%s' "$ws_json" | jq -e '.ok == true' >/dev/null 2>&1; then
    ws_numbers=$(printf '%s' "$ws_json" | \
      jq -r '.result.payload.workspaces[] | select(.displayName | test("^[0-9]+$")) | .number' | sort -n)
  fi
fi
[ -z "$ws_numbers" ] && ws_numbers="$(printf '1\n2\n3\n4\n5')"

first_ws=$(printf '%s' "$ws_numbers" | head -1)

for ws_num in $ws_numbers; do
  # pre: circle when inactive, pre-focus icons when active, hidden when empty
  if [ "$ws_num" = "$first_ws" ]; then
    # Only the first workspace item drives all updates — prevents N parallel script runs
    sketchybar \
      --add item "ws.$ws_num.pre" left \
      --set "ws.$ws_num.pre" \
        icon="○" icon.font="$ICON_FONT" icon.color="$GREY" \
        icon.padding_left="$ICON_PADDING_LEFT" icon.padding_right="$ICON_PADDING_RIGHT" \
        label="" label.padding_right=0 background.drawing=off \
        script="$PLUGIN_DIR/workspace.sh" \
        click_script="omniwmctl command switch-workspace $ws_num >/dev/null 2>&1" \
      --subscribe "ws.$ws_num.pre" omniwm_workspace_change system_woke
  else
    sketchybar \
      --add item "ws.$ws_num.pre" left \
      --set "ws.$ws_num.pre" \
        icon="○" icon.font="$ICON_FONT" icon.color="$GREY" \
        icon.padding_left="$ICON_PADDING_LEFT" icon.padding_right="$ICON_PADDING_RIGHT" \
        label="" label.padding_right=0 background.drawing=off \
        click_script="omniwmctl command switch-workspace $ws_num >/dev/null 2>&1"
  fi

  # focus: focused app icon (AQUA) + name, hidden when inactive
  sketchybar \
    --add item "ws.$ws_num.focus" left \
    --set "ws.$ws_num.focus" \
      drawing=off \
      icon="" icon.font="$ICON_FONT" icon.color="$AQUA" \
      icon.padding_left="$ICON_PADDING_LEFT" icon.padding_right="$ICON_PADDING_RIGHT" \
      label="" label.font="$FONT" label.color="$AQUA" \
      label.padding_left=0 label.padding_right="$LABEL_PADDING_RIGHT" \
      background.drawing=off \
      click_script="omniwmctl command switch-workspace $ws_num >/dev/null 2>&1"

  # post: post-focus icons, hidden when inactive
  sketchybar \
    --add item "ws.$ws_num.post" left \
    --set "ws.$ws_num.post" \
      drawing=off \
      icon="" icon.font="$ICON_FONT" icon.color="$FG" \
      icon.padding_left=3 icon.padding_right="$ICON_PADDING_RIGHT" \
      label="" label.padding_right=0 background.drawing=off \
      click_script="omniwmctl command switch-workspace $ws_num >/dev/null 2>&1"
done

bracket_items=""
for ws_num in $ws_numbers; do
  bracket_items="$bracket_items ws.$ws_num.pre ws.$ws_num.focus ws.$ws_num.post"
done
# shellcheck disable=SC2086
sketchybar --add bracket workspaces $bracket_items
set_capsule workspaces "$CAPSULE_BG" "$CAPSULE_BORDER"
