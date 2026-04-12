# Loaded for login shells.
# Good place for PATH and environment setup.

# Homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Rust
if [[ -r "$HOME/.cargo/env" ]]; then
  . "$HOME/.cargo/env"
fi

# Bun
export BUN_INSTALL="$HOME/.bun"

# Keep PATH clean and deduplicated.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  "$HOME/go/bin"
  $path
)

# OrbStack
[[ -r "$HOME/.orbstack/shell/init.zsh" ]] && source "$HOME/.orbstack/shell/init.zsh"
