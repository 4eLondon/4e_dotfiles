#!/bin/bash
# Refresh current wallpaper and theme without changing wallpaper

STATE_FILE="$HOME/.config/sway/current_wallpaper"

# Check if we have a current wallpaper
if [ ! -f "$STATE_FILE" ]; then
    notify-send -u critical "No Wallpaper" "No current wallpaper set"
    exit 1
fi

CURRENT_WALLPAPER=$(<"$STATE_FILE")

if [ ! -f "$CURRENT_WALLPAPER" ]; then
    notify-send -u critical "Wallpaper Missing" "Current wallpaper file not found"
    exit 1
fi

# Regenerate pywal colors from current wallpaper
wal -i "$CURRENT_WALLPAPER" -n -s -t -e

# Reload apps to pick up refreshed colors
~/.config/sway/reload-apps.sh &

notify-send -t 2000 "Theme Refreshed" "Colors reloaded from current wallpaper"
