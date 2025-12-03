#!/bin/bash
# Generate cava colors from pywal with aggressive gradient (bright colors sooner)

CAVA_CONFIG="$HOME/.config/cava/config"

# Source pywal colors
source ~/.cache/wal/colors.sh

# Backup original config if it doesn't exist
[ ! -f "$CAVA_CONFIG.backup" ] && cp "$CAVA_CONFIG" "$CAVA_CONFIG.backup"

# Use MORE gradient colors so bright ones appear sooner
# This makes the transition faster - you see accent colors at lower volumes
sed -i "s/^gradient_count = .*/gradient_count = 6/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_1 = .*/gradient_color_1 = '$color4'  # Accent immediately/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_2 = .*/gradient_color_2 = '$color6'  # Vibrant cyan/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_3 = .*/gradient_color_3 = '$color14'  # Bright cyan/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_4 = .*/gradient_color_4 = '$color7'  # Light gray/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_5 = .*/gradient_color_5 = '$foreground'  # Lighter/" "$CAVA_CONFIG"
sed -i "s/^gradient_color_6 = .*/gradient_color_6 = '$foreground'  # Brightest at peaks/" "$CAVA_CONFIG"

# Optional: Restart cava if it's running
pkill -USR1 cava 2>/dev/null
