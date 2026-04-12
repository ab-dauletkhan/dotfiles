# Loaded for interactive shells.

# Basic shell behavior
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

# Completion
autoload -Uz compinit
mkdir -p "$HOME/.cache/zsh"
compinit -d "$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"

# Friendly completion behavior
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# bun completions
[[ -r "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# Load extra zsh files from ~/.config/zsh
for file in "$HOME"/.config/zsh/*.zsh(N); do
  source "$file"
done
