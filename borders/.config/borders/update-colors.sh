#!/usr/bin/env bash
set -euo pipefail

BORDERS_BIN="$(command -v borders || true)"

[ -n "$BORDERS_BIN" ] || exit 0

###############################################################################
# EVERFOREST COLORS
#
# Format: 0xAARRGGBB
###############################################################################

INACTIVE="0x334f585e"   # muted gray-green
ACTIVE="0xffa7c080"     # green

###############################################################################
# BORDER STYLE
#
# This standalone config keeps Borders usable without yabai. If you later add a
# window manager that exposes richer window state, this script can become
# dynamic again.
###############################################################################

STYLE="round"
WIDTH="5.0"
HIDPI="on"
AX_FOCUS="on"

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
