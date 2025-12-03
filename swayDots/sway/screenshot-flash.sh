#!/bin/bash

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

if [ "$1" = "fullscreen" ]; then
    filename="$SCREENSHOT_DIR/screenshot-$(date +'%Y%m%d-%H%M%S').png"

    # Create fullscreen white overlay (swaybg)
    swaybg -c "#ffffff" -m fill &
    BG_PID=$!

    # Very quick flash
    sleep 0.1

    # Kill overlay
    kill $BG_PID

    # Take screenshot and copy to clipboard
    grim "$filename" && wl-copy < "$filename"

    # Notification
    if [ -f "$filename" ]; then
        notify-send -t 5000 "Screenshot Saved" "$(basename "$filename")\nCopied to clipboard"
    fi
fi
