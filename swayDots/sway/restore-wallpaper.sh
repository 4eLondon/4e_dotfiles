#!/bin/bash
# Restore wallpaper - SPEED OPTIMIZED

STATE_FILE="$HOME/.config/sway/current_wallpaper"

if [ -f "$STATE_FILE" ]; then
    wallpaper=$(<"$STATE_FILE")
    if [ -f "$wallpaper" ]; then
        exec swaymsg output "*" bg "$wallpaper" fill
    fi
fi

# Fallback
exec swaymsg output "*" bg "#1e1e2e" solid
