#!/usr/bin/env bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
PLUGIN_DIR="${PLUGIN_DIR:-$CONFIG_DIR/plugins}"
PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

pid_file="${TMPDIR:-/tmp}/sketchybar_omniwm_watch.pid"
log_file="${TMPDIR:-/tmp}/sketchybar_omniwm_watch.log"

if [ -r "$pid_file" ]; then
  old_pid="$(cat "$pid_file" 2>/dev/null || true)"
  if [ -n "$old_pid" ] && kill -0 "$old_pid" 2>/dev/null; then
    kill "$old_pid" 2>/dev/null
    sleep 0.3
  fi
fi

printf '%s\n' "$$" > "$pid_file"
trap 'rm -f "$pid_file"' EXIT

trigger_workspace_update() {
  sketchybar --trigger omniwm_workspace_change >/dev/null 2>&1 || true
}

while true; do
  trigger_workspace_update

  if ! command -v omniwmctl >/dev/null 2>&1; then
    sleep 10
    continue
  fi

  if ! omniwmctl ping >/dev/null 2>&1; then
    sleep 5
    continue
  fi

  omniwmctl watch active-workspace,workspace-bar,layout-changed,windows-changed,focus \
    --exec "$PLUGIN_DIR/workspace.sh" >> "$log_file" 2>&1

  sleep 2
done
