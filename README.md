# dotfiles

My macOS dotfiles managed with GNU Stow.

## Structure

- `zsh/` — zsh configuration package
- `scripts/stow.sh` — helper script to stow packages into `$HOME`

## Requirements

- Homebrew
- GNU Stow

Install Stow:

```bash
brew install stow
````

## Usage

From the repo root:

```bash
./scripts/stow.sh zsh
```

This creates symlinks from the package into `$HOME`.

For example:

* `zsh/.zshrc` -> `~/.zshrc`
* `zsh/.zprofile` -> `~/.zprofile`
* `zsh/.zshenv` -> `~/.zshenv`
* `zsh/.config/zsh/aliases.zsh` -> `~/.config/zsh/aliases.zsh`

## Remove a package

```bash
cd ~/gitted/dotfiles
stow -D -t "$HOME" zsh
```
