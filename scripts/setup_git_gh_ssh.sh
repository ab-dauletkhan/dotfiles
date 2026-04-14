#!/usr/bin/env bash
set -Eeuo pipefail

# Interactive, idempotent-ish setup for:
# - Git
# - GitHub CLI (gh)
# - SSH auth for GitHub
# - SSH commit/tag signing for Git
#
# Primary target: macOS.
# Linux support is included for common package managers.
#
# Optional environment variables:
#   GIT_USER_NAME="Your Name"
#   GIT_USER_EMAIL="you@example.com"
#   GITHUB_HOST="github.com"
#   SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
#   SSH_KEY_COMMENT="you@example.com"
#   SSH_KEY_PASSPHRASE=""          # leave unset to be prompted interactively
#   SSH_KEY_TITLE_AUTH="My Mac auth key"
#   SSH_KEY_TITLE_SIGNING="My Mac signing key"
#
# Usage:
#   chmod +x ./setup_git_gh_ssh.sh
#   ./setup_git_gh_ssh.sh

umask 077

if [[ -t 1 ]]; then
  RED=$'\033[0;31m'
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[1;33m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  NC=$'\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

log()     { printf "%s==>%s %s\n" "$BLUE" "$NC" "$*"; }
success() { printf "%s✔%s %s\n"  "$GREEN" "$NC" "$*"; }
warn()    { printf "%s⚠%s %s\n"  "$YELLOW" "$NC" "$*"; }
err()     { printf "%s✖%s %s\n"  "$RED" "$NC" "$*" >&2; }

die() {
  err "$*"
  exit 1
}

trap 'err "Setup failed on line $LINENO while running: $BASH_COMMAND"' ERR

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

is_macos() {
  [[ "$(uname -s)" == "Darwin" ]]
}

is_linux() {
  [[ "$(uname -s)" == "Linux" ]]
}

ask_yes_no() {
  local prompt="$1"
  local default="${2:-Y}"
  local hint='' reply=''

  case "$default" in
    Y|y) hint='[Y/n]' ;;
    N|n) hint='[y/N]' ;;
    *)   hint='[y/n]' ;;
  esac

  if [[ ! -t 0 ]]; then
    [[ "$default" =~ ^[Yy]$ ]]
    return
  fi

  while true; do
    read -r -p "$prompt $hint " reply
    reply="${reply:-$default}"
    case "$reply" in
      Y|y|yes|YES) return 0 ;;
      N|n|no|NO)   return 1 ;;
      *) warn "Please answer y or n." ;;
    esac
  done
}

prompt_if_empty() {
  local var_name="$1"
  local prompt_text="$2"
  local secret="${3:-false}"
  local current_value="${!var_name:-}"

  if [[ -n "$current_value" ]]; then
    return 0
  fi

  if [[ -t 0 ]]; then
    if [[ "$secret" == "true" ]]; then
      read -r -s -p "$prompt_text" current_value
      printf '\n'
    else
      read -r -p "$prompt_text" current_value
    fi
    printf -v "$var_name" '%s' "$current_value"
    export "$var_name"
  fi

  [[ -n "${!var_name:-}" ]] || die "$var_name is required. Set it as an environment variable or answer the prompt."
}

portable_version_ge() {
  # Returns success if current >= required
  # Example: portable_version_ge 2.34.0 2.40.1  -> success
  #          portable_version_ge 2.34.0 2.33.9  -> failure
  local required="$1"
  local current="$2"
  local IFS=.
  local -a req_parts cur_parts
  local i req cur len

  read -r -a req_parts <<< "$required"
  read -r -a cur_parts <<< "$current"

  len=${#req_parts[@]}
  if (( ${#cur_parts[@]} > len )); then
    len=${#cur_parts[@]}
  fi

  for (( i=0; i<len; i++ )); do
    req=${req_parts[i]:-0}
    cur=${cur_parts[i]:-0}

    # Force base-10 so values like 08 are handled safely.
    ((10#$cur > 10#$req)) && return 0
    ((10#$cur < 10#$req)) && return 1
  done

  return 0
}

ensure_package_manager() {
  if is_macos && ! have_cmd brew; then
    die "Homebrew is not installed. Install it first, then rerun this script."
  fi
}

install_pkg() {
  local pkg="$1"

  if is_macos; then
    ensure_package_manager
    brew install "$pkg"
    return 0
  fi

  if have_cmd apt-get; then
    sudo apt-get update
    sudo apt-get install -y "$pkg"
  elif have_cmd dnf; then
    sudo dnf install -y "$pkg"
  elif have_cmd yum; then
    sudo yum install -y "$pkg"
  elif have_cmd pacman; then
    sudo pacman -Sy --noconfirm "$pkg"
  elif have_cmd zypper; then
    sudo zypper install -y "$pkg"
  else
    die "No supported package manager found to install '$pkg'."
  fi
}

ensure_git() {
  if have_cmd git; then
    success "git is already installed: $(git --version)"
    return 0
  fi

  log "git was not found. Installing it now..."
  install_pkg git
  have_cmd git || die "git installation appears to have failed."
  success "git installed: $(git --version)"
}

ensure_gh() {
  if have_cmd gh; then
    success "gh is already installed: $(gh --version | head -n1)"
    return 0
  fi

  log "GitHub CLI (gh) was not found. Installing it now..."
  if is_macos; then
    install_pkg gh
  else
    install_pkg gh || die "Could not install gh automatically on this Linux system. Install gh manually, then rerun this script."
  fi

  have_cmd gh || die "gh installation appears to have failed."
  success "gh installed: $(gh --version | head -n1)"
}

ensure_ssh_tools() {
  if have_cmd ssh-keygen && have_cmd ssh-agent && have_cmd ssh-add; then
    success "SSH tools are available."
    return 0
  fi

  log "SSH tools were not fully available. Installing OpenSSH tools..."

  if is_macos; then
    warn "OpenSSH tools are usually built into macOS."
  elif have_cmd apt-get; then
    install_pkg openssh-client
  elif have_cmd dnf || have_cmd yum || have_cmd zypper || have_cmd pacman; then
    install_pkg openssh
  fi

  have_cmd ssh-keygen || die "ssh-keygen is not available after attempted installation."
  have_cmd ssh-agent  || die "ssh-agent is not available after attempted installation."
  have_cmd ssh-add    || die "ssh-add is not available after attempted installation."
  success "SSH tools are available."
}

choose_ssh_add_bin() {
  # On macOS, prefer Apple's ssh-add so --apple-use-keychain works.
  if is_macos && [[ -x /usr/bin/ssh-add ]]; then
    printf '/usr/bin/ssh-add\n'
  else
    command -v ssh-add
  fi
}

get_machine_name() {
  if is_macos && have_cmd scutil; then
    scutil --get ComputerName 2>/dev/null || hostname
  else
    hostname
  fi
}

get_ssh_key_passphrase() {
  if [[ -n "${SSH_KEY_PASSPHRASE:-}" ]]; then
    return 0
  fi

  if [[ ! -t 0 ]]; then
    SSH_KEY_PASSPHRASE=''
    export SSH_KEY_PASSPHRASE
    return 0
  fi

  if ask_yes_no "Protect the SSH key with a passphrase?" Y; then
    local first='' second=''
    while true; do
      read -r -s -p "Enter SSH key passphrase: " first
      printf '\n'
      read -r -s -p "Confirm SSH key passphrase: " second
      printf '\n'

      if [[ "$first" != "$second" ]]; then
        warn "Passphrases did not match. Please try again."
        continue
      fi

      SSH_KEY_PASSPHRASE="$first"
      export SSH_KEY_PASSPHRASE
      return 0
    done
  fi

  SSH_KEY_PASSPHRASE=''
  export SSH_KEY_PASSPHRASE
}

ensure_ssh_key() {
  local ssh_key_path="$1"
  local email="$2"
  local comment="${SSH_KEY_COMMENT:-$email}"
  local passphrase="${SSH_KEY_PASSPHRASE:-}"

  mkdir -p "$(dirname "$ssh_key_path")"
  chmod 700 "$HOME/.ssh" 2>/dev/null || true

  if [[ -f "$ssh_key_path" && -f "$ssh_key_path.pub" ]]; then
    success "SSH key already exists at $ssh_key_path"
    return 0
  fi

  log "No SSH key found at $ssh_key_path"
  log "Generating a new ed25519 SSH key..."
  ssh-keygen -t ed25519 -C "$comment" -f "$ssh_key_path" -N "$passphrase"
  chmod 600 "$ssh_key_path"
  chmod 644 "$ssh_key_path.pub"
  success "SSH key generated."
}

ssh_key_fingerprint() {
  local pubkey_path="$1"
  ssh-keygen -lf "$pubkey_path" | awk '{print $2}'
}

start_ssh_agent_if_needed() {
  local ssh_add_bin="$1"

  if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    set +e
    "$ssh_add_bin" -l >/dev/null 2>&1
    local rc=$?
    set -e

    # rc=0 => agent reachable and has identities
    # rc=1 => agent reachable but has no identities
    if [[ $rc -eq 0 || $rc -eq 1 ]]; then
      success "ssh-agent is already running."
      return 0
    fi
  fi

  log "Starting ssh-agent for this shell session..."
  eval "$(ssh-agent -s)" >/dev/null
  success "ssh-agent started."
}

add_key_to_agent() {
  local ssh_key_path="$1"
  local ssh_add_bin="$2"
  local fingerprint current_keys

  fingerprint="$(ssh_key_fingerprint "$ssh_key_path.pub")"
  current_keys="$("$ssh_add_bin" -l 2>/dev/null || true)"

  if grep -Fq "$fingerprint" <<< "$current_keys"; then
    success "SSH key is already loaded in ssh-agent."
    return 0
  fi

  log "Adding SSH key to ssh-agent..."

  if is_macos; then
    if [[ -n "${SSH_KEY_PASSPHRASE:-}" ]]; then
      if "$ssh_add_bin" --apple-use-keychain "$ssh_key_path" >/dev/null 2>&1; then
        success "SSH key added to agent and Apple Keychain."
        return 0
      fi

      if "$ssh_add_bin" -K "$ssh_key_path" >/dev/null 2>&1; then
        success "SSH key added to agent and Apple Keychain."
        return 0
      fi
    fi
  fi

  if "$ssh_add_bin" "$ssh_key_path" >/dev/null 2>&1; then
    success "SSH key added to ssh-agent."
  else
    die "ssh-add failed for $ssh_key_path"
  fi
}

replace_managed_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"
  local content="$4"
  local tmp

  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skip=1; next }
    $0 == end   { skip=0; next }
    !skip { print }
  ' "$file" > "$tmp"

  {
    cat "$tmp"
    printf '\n%s\n' "$start_marker"
    printf '%s\n' "$content"
    printf '%s\n' "$end_marker"
  } > "$file"

  rm -f "$tmp"
}

ensure_ssh_config() {
  local ssh_key_path="$1"
  local host="$2"
  local config_file="$HOME/.ssh/config"
  local start_marker="# >>> git-gh-ssh-setup $host >>>"
  local end_marker="# <<< git-gh-ssh-setup $host <<<"
  local use_keychain_line=''
  local block=''

  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"

  # Only add UseKeychain when we actually have a passphrase to store.
  if is_macos && [[ -n "${SSH_KEY_PASSPHRASE:-}" ]]; then
    use_keychain_line='  UseKeychain yes'
  fi

  block="Host $host
  HostName $host
  User git
  AddKeysToAgent yes
$use_keychain_line
  IdentitiesOnly yes
  IdentityFile $ssh_key_path"

  replace_managed_block "$config_file" "$start_marker" "$end_marker" "$block"
  chmod 600 "$config_file"
  success "SSH config ensured at $config_file"
}

ensure_gh_auth() {
  local host="$1"

  if gh auth status -h "$host" >/dev/null 2>&1; then
    success "gh is already authenticated for $host"
  else
    log "gh is not authenticated for $host"
    log "Opening browser-based GitHub login..."
    gh auth login -h "$host" --git-protocol ssh --web --skip-ssh-key
    success "gh authentication complete."
  fi

  log "Configuring Git to use gh as credential helper..."
  gh auth setup-git -h "$host"
  success "gh credential helper configured for Git."
}

gh_public_key_exists() {
  local api_path="$1"
  local pubkey_path="$2"
  local key_text

  key_text="$(tr -d '\n' < "$pubkey_path")"
  gh api "$api_path" --paginate --jq '.[].key' 2>/dev/null | grep -Fxq "$key_text"
}

ensure_gh_key_permissions() {
  local host="$1"

  # Try reading both auth keys and signing keys.
  # If either check fails because the token lacks scope, refresh once.
  if gh_public_key_exists user/keys "$SSH_KEY_PATH.pub" && gh_public_key_exists user/ssh_signing_keys "$SSH_KEY_PATH.pub"; then
    success "gh already has enough access to inspect your SSH and signing keys."
    return 0
  fi

  log "Refreshing gh auth scopes so the script can manage SSH keys..."
  warn "GitHub may prompt you once here."
  gh auth refresh -h "$host" -s admin:public_key >/dev/null
  success "gh scopes refreshed."
}

ensure_github_ssh_key() {
  local pubkey_path="$1"
  local title="$2"
  local type="$3"
  local api_path="$4"

  if gh_public_key_exists "$api_path" "$pubkey_path"; then
    success "GitHub already has this SSH $type key."
    return 0
  fi

  log "Uploading SSH $type key to GitHub..."
  gh ssh-key add "$pubkey_path" --type "$type" --title "$title"
  success "Uploaded SSH $type key to GitHub."
}

configure_git_identity() {
  local name="$1"
  local email="$2"
  local old_name old_email

  old_name="$(git config --global --get user.name || true)"
  old_email="$(git config --global --get user.email || true)"

  log "Configuring global Git identity..."
  [[ -n "$old_name"  ]] && log "Current user.name : $old_name"
  [[ -n "$old_email" ]] && log "Current user.email: $old_email"

  git config --global init.defaultBranch main
  git config --global user.name "$name"
  git config --global user.email "$email"
  success "Global Git identity configured."
}

configure_git_ssh_signing() {
  local pubkey_path="$1"
  local git_version_raw git_version

  git_version_raw="$(git --version)"
  git_version="$(awk '{print $3}' <<< "$git_version_raw")"

  if ! portable_version_ge "2.34.0" "$git_version"; then
    warn "Git $git_version does not support SSH commit signing. Upgrade Git to 2.34+ to enable signing."
    return 0
  fi

  log "Enabling SSH commit/tag signing in Git..."
  git config --global gpg.format ssh
  git config --global user.signingkey "$pubkey_path"
  git config --global commit.gpgsign true
  git config --global tag.gpgsign true
  success "Git SSH signing configured."
}

print_summary() {
  local ssh_key_path="$1"

  printf '\n'
  success "Setup complete."
  printf '\n%sGit summary%s\n' "$BOLD" "$NC"
  printf '  user.name      = %s\n' "$(git config --global --get user.name || true)"
  printf '  user.email     = %s\n' "$(git config --global --get user.email || true)"
  printf '  gpg.format     = %s\n' "$(git config --global --get gpg.format || true)"
  printf '  signing key    = %s\n' "$(git config --global --get user.signingkey || true)"
  printf '  commit.gpgsign = %s\n' "$(git config --global --get commit.gpgsign || true)"
  printf '  tag.gpgsign    = %s\n' "$(git config --global --get tag.gpgsign || true)"

  printf '\n%sSSH files%s\n' "$BOLD" "$NC"
  printf '  private key    = %s\n' "$ssh_key_path"
  printf '  public key     = %s\n' "$ssh_key_path.pub"

  printf '\n%sUseful checks%s\n' "$BOLD" "$NC"
  printf '  gh auth status\n'
  printf '  gh ssh-key list\n'
  printf '  ssh -T git@%s\n' "$GITHUB_HOST"
  printf '  git commit -S -m "test signed commit"\n'

  warn "Avoid running 'gh auth token' unless you truly need it. It prints a live token."
}

main() {
  log "Starting Git + gh + SSH setup..."

  export GITHUB_HOST="${GITHUB_HOST:-github.com}"
  export SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"

  prompt_if_empty GIT_USER_NAME  "Git user name: "
  prompt_if_empty GIT_USER_EMAIL "Git user email (recommended: one associated with your GitHub account): "

  get_ssh_key_passphrase

  local machine_name ssh_add_bin
  machine_name="$(get_machine_name)"
  ssh_add_bin="$(choose_ssh_add_bin)"

  export SSH_KEY_TITLE_AUTH="${SSH_KEY_TITLE_AUTH:-$machine_name auth key}"
  export SSH_KEY_TITLE_SIGNING="${SSH_KEY_TITLE_SIGNING:-$machine_name signing key}"

  ensure_git
  ensure_gh
  ensure_ssh_tools

  configure_git_identity "$GIT_USER_NAME" "$GIT_USER_EMAIL"
  ensure_ssh_key "$SSH_KEY_PATH" "$GIT_USER_EMAIL"
  ensure_ssh_config "$SSH_KEY_PATH" "$GITHUB_HOST"
  start_ssh_agent_if_needed "$ssh_add_bin"
  add_key_to_agent "$SSH_KEY_PATH" "$ssh_add_bin"

  ensure_gh_auth "$GITHUB_HOST"
  ensure_gh_key_permissions "$GITHUB_HOST"

  if ask_yes_no "Upload this key to GitHub for SSH authentication?" Y; then
    ensure_github_ssh_key "$SSH_KEY_PATH.pub" "$SSH_KEY_TITLE_AUTH" authentication user/keys
  else
    warn "Skipped uploading SSH authentication key to GitHub."
  fi

  if ask_yes_no "Upload this same key to GitHub for commit signing?" Y; then
    ensure_github_ssh_key "$SSH_KEY_PATH.pub" "$SSH_KEY_TITLE_SIGNING" signing user/ssh_signing_keys
  else
    warn "Skipped uploading SSH signing key to GitHub."
  fi

  if ask_yes_no "Enable SSH commit and tag signing globally in Git?" Y; then
    configure_git_ssh_signing "$SSH_KEY_PATH.pub"
  else
    warn "Skipped Git SSH signing configuration."
  fi

  print_summary "$SSH_KEY_PATH"
}

main "$@"
