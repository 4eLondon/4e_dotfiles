#!/bin/bash
# ~/.config/sway/generate-mako-config.sh

# Generate mako config from pywal colors
CONFIG_FILE="$HOME/.config/mako/config"
TEMPLATE_FILE="$HOME/.config/mako/config.template"

# If template doesn't exist, create it from the config above
if [ ! -f "$TEMPLATE_FILE" ]; then
    mkdir -p "$(dirname "$TEMPLATE_FILE")"
    cat > "$TEMPLATE_FILE" << 'EOF'
# Generated from pywal colors
font=JetBrainsMono Nerd Font 10
text-color=@foreground

width=300
height=100
margin=10
padding=10
border-size=2
border-radius=6

anchor=top-right
layer=overlay

background-color=@color0
border-color=@color1
progress-color=over @color1

default-timeout=5000
ignore-timeout=no

max-history=50
max-visible=3

on-button-left=dismiss
on-button-middle=dismiss-all
on-button-right=dismiss

group-by=app-name
icons=1
icon-location=left
icon-path=/usr/share/icons/Papirus/16x16/apps/:/usr/share/icons/hicolor/16x16/apps/

progress=1
format=<span font_weight='bold'>%s</span>\n%b

[urgency=low]
background-color=@color0
border-color=@color2
text-color=@color15

[urgency=normal]
background-color=@color0
border-color=@color1
text-color=@color15

[urgency=high]
background-color=@color0
border-color=@color9
text-color=@color9
default-timeout=10000
EOF
fi

# Source pywal colors
if [ -f "$HOME/.cache/wal/colors.sh" ]; then
    source "$HOME/.cache/wal/colors.sh"
else
    # Fallback to default colors if pywal hasn't run yet
    color0="#282828"
    color1="#cc241d"
    color2="#98971a"
    color9="#fb4934"
    color15="#ebdbb2"
    foreground="#ebdbb2"
fi

color0="${color0}66"

# Replace placeholders with actual colors
sed -e "s|@color0|$color0|g" \
    -e "s|@color1|$color1|g" \
    -e "s|@color2|$color2|g" \
    -e "s|@color9|$color9|g" \
    -e "s|@color15|$foreground|g" \
    -e "s|@foreground|$foreground|g" \
    "$TEMPLATE_FILE" > "$CONFIG_FILE"

# Reload mako if running
if pgrep -x mako > /dev/null; then
    makoctl reload
fi

echo "Mako config updated with pywal colors"
