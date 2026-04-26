# config.nu
#
# Installed by:
# version = "0.112.2"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, 
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R
#     # ~/.config/nushell/config.nu

# Disable welcome banner
$env.config.show_banner = false

# Editor used by `config nu`
$env.config.buffer_editor = "nvim"

# -----------------------------
# Aliases
# -----------------------------

alias ll = eza -lah --icons=auto --git --group-directories-first
alias la = eza -la --icons=auto --git --group-directories-first
alias lt = eza --tree --level=2 --icons=auto --group-directories-first
alias lta = eza --tree --level=3 --icons=auto --group-directories-first

alias b = bat --paging=never
alias v = nvim
alias c = clear

alias gst = git status
alias ga = git add
alias gaa = git add --all
alias gc = git commit
alias gcm = git commit -m
alias gp = git push
alias gpl = git pull
alias gl = git log --oneline --graph --decorate --all

alias jst = jj status
alias jl = jj log

# -----------------------------
# Zoxide
# -----------------------------

let zoxide_init = ($nu.default-config-dir | path join "zoxide.nu")

if ($zoxide_init | path exists) {
    source $zoxide_init
}

# -----------------------------
# Useful custom commands
# -----------------------------

def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

def ports [] {
    ^lsof -iTCP -sTCP:LISTEN -n -P
}

def killport [port: int] {
    let pids = (^lsof -ti $"tcp:($port)" | lines)

    if ($pids | is-empty) {
        print $"No process found on port ($port)"
    } else {
        $pids | each {|pid| ^kill -9 $pid }
        print $"Killed process on port ($port)"
    }
}

def pathlist [] {
    $env.PATH
}

# -----------------------------
# External completions via Carapace
# -----------------------------

let carapace_completer = {|spans: list<string>|
    ^carapace $spans.0 nushell ...$spans | from json
}

$env.config.completions.external = {
    enable: true
    completer: $carapace_completer
}
