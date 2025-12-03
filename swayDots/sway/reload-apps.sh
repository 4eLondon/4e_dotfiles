#!/bin/bash
# Reload apps to apply pywal colors - OPTIMIZED FOR SPEED

# Generate and apply mako config
~/.config/sway/reload-mako.sh &

# All operations in parallel with &
pgrep -x waybar > /dev/null && { killall waybar; waybar > /dev/null 2>&1 & }
pkill -x wofi 2>/dev/null &
pgrep -x mako > /dev/null && makoctl reload &

# Update cava colors
~/.config/sway/update-cava-colors.sh &

# Reload kitty colors in all running instances (real-time update!)
killall -SIGUSR1 kitty 2>/dev/null &

# Fire and forget notification
notify-send -t 3000 "Theme Applied" "Colors updated" &
