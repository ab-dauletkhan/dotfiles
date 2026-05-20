#!/usr/bin/env bash

# Workspaces
export ICON_WS_TERMINAL="󰆍"
export ICON_WS_BROWSER="󰖟"
export ICON_WS_CODING="󰌠"
export ICON_WS_AI="󰚩"
export ICON_WS_READING="󰂺"
export ICON_WS_OTHERS="󰒓"
export ICON_WS_DEFAULT="󰮯"

# Apps
export ICON_APP_DEFAULT="󰣆"
export ICON_APP_TERMINAL="󰆍"
export ICON_APP_BROWSER="󰖟"
export ICON_APP_AI="󰚩"
export ICON_APP_READING="󰈙"
export ICON_APP_FINDER="󰀶"
export ICON_APP_ZED="󰨞"

get_app_icon() {
  case "$1" in
    Ghostty|Terminal|iTerm2|Alacritty|WezTerm|Kitty|Hyper)
      echo "$ICON_APP_TERMINAL" ;;
    "Brave Browser"|"Google Chrome"|Firefox|Safari|Arc|"Microsoft Edge"|Opera|Vivaldi)
      echo "$ICON_APP_BROWSER" ;;
    Zed|"Visual Studio Code"|Cursor|"Sublime Text"|Nova|BBEdit)
      echo "$ICON_APP_ZED" ;;
    Xcode)                                          echo "󰀵" ;;
    IntelliJ\ IDEA|WebStorm|PyCharm|GoLand|Rider|CLion|DataGrip)
                                                    echo "󰧱" ;;
    Claude|Codex|ChatGPT|"GitHub Copilot")          echo "$ICON_APP_AI" ;;
    Slack)                                          echo "󰒱" ;;
    Discord)                                        echo "󰙯" ;;
    Telegram)                                       echo "󰔁" ;;
    Signal|Messages)                                echo "󰍡" ;;
    WhatsApp)                                       echo "󰖣" ;;
    Zoom|FaceTime|"Google Meet"|"Microsoft Teams"|Skype)
                                                    echo "󰕧" ;;
    Mail|Spark|Mimestream|Airmail|Superhuman)       echo "󰇰" ;;
    Spotify)                                        echo "󰓇" ;;
    Music)                                          echo "󰎆" ;;
    VLC|IINA|Infuse|"Plex Media Player")            echo "󰕦" ;;
    Preview|Books|"Adobe Acrobat")                  echo "$ICON_APP_READING" ;;
    Obsidian)                                       echo "󰴋" ;;
    Notion)                                         echo "󰒓" ;;
    Bear|Notes)                                     echo "󰠮" ;;
    Craft|Ulysses)                                  echo "󰎚" ;;
    Calendar)                                       echo "󰃶" ;;
    Reminders|"Things 3"|Things)                    echo "󰄵" ;;
    Figma|Sketch|Canva)                             echo "󰆔" ;;
    GIMP|Pixelmator|"Affinity Designer"|"Affinity Photo")
                                                    echo "󰋫" ;;
    Finder|PathFinder|ForkLift)                     echo "$ICON_APP_FINDER" ;;
    TablePlus|"Sequel Pro"|DBngin)                  echo "󰆼" ;;
    Proxyman|Paw|Insomnia|Postman)                  echo "󰛶" ;;
    Tower|Fork|SourceTree|"GitHub Desktop")         echo "󰊢" ;;
    1Password|Bitwarden)                            echo "󰷠" ;;
    Raycast|Alfred)                                 echo "󰍉" ;;
    "Activity Monitor")                             echo "󰓱" ;;
    "System Preferences"|"System Settings")         echo "󰒓" ;;
    *)                                              echo "$ICON_APP_DEFAULT" ;;
  esac
}

# Utility
export ICON_INPUT="󰌌"
export ICON_CLOCK="󰃰"

# Battery
export ICON_BATTERY_FULL="󰁹"
export ICON_BATTERY_80="󰂁"
export ICON_BATTERY_50="󰁾"
export ICON_BATTERY_30="󰁻"
export ICON_BATTERY_LOW="󰁺"
export ICON_BATTERY_CHARGING="󰂄"
export ICON_BATTERY_HOLD="󰚥"
