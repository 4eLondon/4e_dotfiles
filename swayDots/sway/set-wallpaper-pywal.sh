#!/bin/bash
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
STATE_FILE="$HOME/.config/sway/current_wallpaper"
# Get list of wallpapers
WALLPAPERS=($(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \)))
if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    notify-send -t 100000 "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi
# Read current wallpaper
CURRENT=""
if [ -f "$STATE_FILE" ]; then
    CURRENT=$(cat "$STATE_FILE")
fi
# Find current index
CURRENT_INDEX=0
for i in "${!WALLPAPERS[@]}"; do
    if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
        CURRENT_INDEX=$i
        break
    fi
done
# Calculate new index
if [ "$1" = "next" ]; then
    NEW_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
elif [ "$1" = "prev" ]; then
    NEW_INDEX=$(( (CURRENT_INDEX - 1 + ${#WALLPAPERS[@]}) % ${#WALLPAPERS[@]} ))
else
    NEW_INDEX=$(shuf -i 0-$((${#WALLPAPERS[@]} - 1)) -n 1)
fi
NEW_WALLPAPER="${WALLPAPERS[$NEW_INDEX]}"
# Apply with pywal
wal -i "$NEW_WALLPAPER" -n -s -t -e
# Set wallpaper
swaymsg output "*" bg "$NEW_WALLPAPER" fill
# Save state
echo "$NEW_WALLPAPER" > "$STATE_FILE"
# Reload apps to apply new colors
~/.config/sway/reload-apps.sh
