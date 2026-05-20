#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/settings.sh"
source "$CONFIG_DIR/icons.sh"

command -v omniwmctl >/dev/null 2>&1 || exit 0
command -v jq       >/dev/null 2>&1 || exit 0

workspaces_json=$(omniwmctl query workspaces --format json 2>/dev/null || true)
windows_json=$(omniwmctl query windows     --format json 2>/dev/null || true)

printf '%s' "$workspaces_json" | jq -e '.ok == true' >/dev/null 2>&1 || exit 0

active_ws=$(printf '%s' "$workspaces_json" | \
  jq -r '.result.payload.workspaces[] | select(.isFocused == true) | .number')

has_windows=$(printf '%s' "$windows_json" | jq -e '.ok == true' >/dev/null 2>&1 && echo 1 || echo 0)

# --- State tracking for typewriter animation ---
state_dir="/tmp/sketchybar_ws"
mkdir -p "$state_dir" 2>/dev/null

prev_focused=$(cat "$state_dir/focused"   2>/dev/null || echo "")
prev_ws=$(cat      "$state_dir/active_ws" 2>/dev/null || echo "")
gen=$(( $(cat      "$state_dir/gen"       2>/dev/null || echo 0) + 1 ))

# Determine focused app before the loop (needed for state tracking)
focused_name_global=""
if [ "$has_windows" = "1" ] && [ -n "$active_ws" ]; then
  focused_name_global=$(printf '%s' "$windows_json" | \
    jq -r --argjson aws "$active_ws" \
      'first(.result.payload.windows[] | select(.isFocused == true and .workspace.number == $aws) | .app.name) // ""')
fi

# Persist state
printf '%s' "$gen"                 > "$state_dir/gen"
printf '%s' "$focused_name_global" > "$state_dir/focused"
printf '%s' "$active_ws"           > "$state_dir/active_ws"

# Typewriter only when focus changes within the same workspace
do_typewriter=0
if [ "$prev_ws" = "$active_ws" ] \
   && [ -n "$prev_focused" ] \
   && [ -n "$focused_name_global" ] \
   && [ "$focused_name_global" != "$prev_focused" ]; then
  do_typewriter=1
fi

# --- Build all bar updates into one atomic call ---
declare -a args=()

while read -r ws_num; do
  window_count=0
  ws_windows="[]"
  if [ "$has_windows" = "1" ]; then
    ws_windows=$(printf '%s' "$windows_json" | \
      jq -c --argjson n "$ws_num" '[.result.payload.windows[] | select(.workspace.number == $n)]')
    window_count=$(printf '%s' "$ws_windows" | jq 'length')
  fi

  if [ "$ws_num" = "$active_ws" ] && [ "$window_count" -gt 0 ]; then
    focused_idx=$(printf '%s' "$ws_windows" | jq 'map(.isFocused) | index(true) // 0')
    focused_name=$(printf '%s' "$ws_windows" | jq -r ".[$focused_idx].app.name // \"\"")
    focused_icon="$(get_app_icon "$focused_name")"

    pre_icons=$(printf '%s' "$ws_windows" | \
      jq -r --argjson fi "$focused_idx" '.[:$fi][].app.name' \
      | while IFS= read -r app; do printf "%s " "$(get_app_icon "$app")"; done)
    pre_icons="${pre_icons% }"

    post_icons=$(printf '%s' "$ws_windows" | \
      jq -r --argjson fi "$focused_idx" '.[($fi+1):][].app.name' \
      | while IFS= read -r app; do printf "%s " "$(get_app_icon "$app")"; done)
    post_icons="${post_icons% }"

    if [ -n "$pre_icons" ]; then
      args+=(--animate tanh 20
             --set "ws.$ws_num.pre" drawing=on "icon=$pre_icons"
             "icon.color=$FG" "icon.padding_left=$ICON_PADDING_LEFT")
      focus_left=3
    else
      args+=(--set "ws.$ws_num.pre" drawing=off)
      focus_left="$ICON_PADDING_LEFT"
    fi

    if [ "$do_typewriter" = "1" ]; then
      # Icon updates immediately; label text animated in background
      args+=(--animate tanh 20
             --set "ws.$ws_num.focus" drawing=on
             "icon=$focused_icon" "icon.color=$AQUA" "icon.padding_left=$focus_left"
             "label.color=$AQUA")

      # Background: remove old name char by char, type new name char by char
      focus_item="ws.$ws_num.focus"
      old_name="$prev_focused"
      new_name="$focused_name"
      gen_snap="$gen"
      (
        check_gen() { [ "$(cat "$state_dir/gen" 2>/dev/null)" = "$gen_snap" ]; }

        text="$old_name"
        while [ "${#text}" -gt 0 ]; do
          check_gen || exit 0
          text="${text%?}"
          sketchybar --set "$focus_item" "label=$text"
          sleep 0.03
        done

        typed=""
        i=0
        while [ "$i" -lt "${#new_name}" ]; do
          check_gen || exit 0
          typed="${typed}${new_name:$i:1}"
          sketchybar --set "$focus_item" "label=$typed"
          sleep 0.05
          i=$(( i + 1 ))
        done
      ) &
      disown
    else
      args+=(--animate tanh 20
             --set "ws.$ws_num.focus" drawing=on
             "icon=$focused_icon" "icon.color=$AQUA" "icon.padding_left=$focus_left"
             "label=$focused_name" "label.color=$AQUA")
    fi

    if [ -n "$post_icons" ]; then
      args+=(--animate tanh 20
             --set "ws.$ws_num.post" drawing=on "icon=$post_icons" "icon.color=$FG")
    else
      args+=(--set "ws.$ws_num.post" drawing=off)
    fi

  elif [ "$window_count" -gt 0 ]; then
    # Non-empty, inactive: unfilled circle in yellow
    args+=(--animate tanh 20
           --set "ws.$ws_num.pre" drawing=on icon=○
           "icon.color=$YELLOW" "icon.padding_left=$ICON_PADDING_LEFT")
    args+=(--set "ws.$ws_num.focus" drawing=off)
    args+=(--set "ws.$ws_num.post"  drawing=off)

  else
    # Empty: unfilled circle in grey (always visible)
    args+=(--animate tanh 20
           --set "ws.$ws_num.pre" drawing=on icon=○
           "icon.color=$GREY" "icon.padding_left=$ICON_PADDING_LEFT")
    args+=(--set "ws.$ws_num.focus" drawing=off)
    args+=(--set "ws.$ws_num.post"  drawing=off)
  fi

done < <(printf '%s' "$workspaces_json" | \
  jq -r '.result.payload.workspaces[] | select(.displayName | test("^[0-9]+$")) | .number' | sort -n)

[ "${#args[@]}" -gt 0 ] && sketchybar "${args[@]}"
