# dotfiles

macOS dotfiles managed with GNU Stow.

## Requirements

- Homebrew
- GNU Stow

Install Stow:

```sh
brew install stow
```

## Packages

- `zsh`
- `wezterm`
- `starship`
- `gh`
- `karabiner`
- `zed`
- `flashspace`
- `borders`

Each package mirrors the path it should create in `$HOME`.

Examples:

- `zsh/.zshrc` -> `~/.zshrc`
- `wezterm/.config/wezterm/wezterm.lua` -> `~/.config/wezterm/wezterm.lua`
- `zed/.config/zed/settings.json` -> `~/.config/zed/settings.json`

## Usage

From the repo root, stow one package:

```sh
./scripts/stow.sh zsh
```

Stow the default set:

```sh
./scripts/stow.sh
```

Remove one package:

```sh
stow -D -t "$HOME" zsh
```

Restow after changing files:

```sh
./scripts/stow.sh zsh
```
