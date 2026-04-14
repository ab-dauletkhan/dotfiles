#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  echo "stow is not installed"
  echo "Install it with: brew install stow"
  exit 1
fi

cd "$DOTFILES_DIR"

if [ "$#" -eq 0 ]; then
  set -- zsh wezterm starship gh karabiner zed flashspace borders
fi

stow --restow -t "$HOME" "$@"

echo
echo "Stowed packages: $*"
