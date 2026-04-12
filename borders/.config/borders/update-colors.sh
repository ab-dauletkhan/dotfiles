#!/usr/bin/env bash
set -euo pipefail

BORDERS_BIN="$(command -v borders || true)"
YABAI_BIN="$(command -v yabai || true)"
JQ_BIN="$(command -v jq || true)"

[ -n "$BORDERS_BIN" ] || exit 0
[ -n "$YABAI_BIN" ] || exit 0
[ -n "$JQ_BIN" ] || exit 0

###############################################################################
# EVERFOREST COLORS
#
# Format: 0xAARRGGBB
###############################################################################

INACTIVE="0x334f585e"     # muted gray-green
BSP_ACTIVE="0xffa7c080"   # green
FLOAT_ACTIVE="0xffdbbc7f" # yellow
STACK_ACTIVE="0xff7fbbb3" # aqua

###############################################################################
# BORDER STYLE
###############################################################################

STYLE="round"
WIDTH="5.0"
HIDPI="on"
AX_FOCUS="on"

###############################################################################
# FALLBACK
#
# If no focused window is available, start/update borders with the normal BSP
# active color so the process is still alive and sane.
###############################################################################

if ! WIN_JSON="$("$YABAI_BIN" -m query --windows --window 2>/dev/null)"; then
  exec "$BORDERS_BIN" \
    style="$STYLE" \
    width="$WIDTH" \
    hidpi="$HIDPI" \
    ax_focus="$AX_FOCUS" \
    active_color="$BSP_ACTIVE" \
    inactive_color="$INACTIVE"
fi

APP="$(printf '%s\n' "$WIN_JSON" | "$JQ_BIN" -r '.app // ""')"
SPACE_ID="$(printf '%s\n' "$WIN_JSON" | "$JQ_BIN" -r '.space // 0')"
IS_FLOATING="$(printf '%s\n' "$WIN_JSON" | "$JQ_BIN" -r '."is-floating" // false')"
STACK_INDEX="$(printf '%s\n' "$WIN_JSON" | "$JQ_BIN" -r '."stack-index" // 0')"

# Default category: normal managed BSP focus
ACTIVE="$BSP_ACTIVE"

###############################################################################
# CATEGORY 1: FLOATING / UTILITY APPS
#
# These apps are usually better treated as "special utility focus" rather than
# normal tiling focus.
#
# Edit this list however you want.
###############################################################################

if [ "$IS_FLOATING" = "true" ]; then
  ACTIVE="$FLOAT_ACTIVE"
fi

###############################################################################
# CATEGORY 2: STACK
#
# If the current space layout is stack, or the focused window has a stack index,
# prefer the stack color.
###############################################################################

SPACE_LAYOUT="$("$YABAI_BIN" -m config --space "$SPACE_ID" layout 2>/dev/null || echo bsp)"

if [ "$SPACE_LAYOUT" = "stack" ] || [ "${STACK_INDEX:-0}" -gt 0 ]; then
  ACTIVE="$STACK_ACTIVE"
fi

###############################################################################
# APPLY / UPDATE BORDERS
#
# JankyBorders updates the running process when invoked again with new args.
###############################################################################

exec "$BORDERS_BIN" \
  style="$STYLE" \
  width="$WIDTH" \
  hidpi="$HIDPI" \
  ax_focus="$AX_FOCUS" \
  active_color="$ACTIVE" \
  inactive_color="$INACTIVE"
