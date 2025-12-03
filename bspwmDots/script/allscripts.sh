
# First, create the volume script
home.file.".config/polybar/scripts/volume.sh" = {
  text = ''
    #!/bin/sh

    # Get volume and mute in one call
    read VOLUME MUTED <<< $(pulsemixer --get-volume --get-mute | awk '{print $1, $2}')

    # Function to get icon
    get_volume_icon() {
        if [ "$MUTED" = "1" ] || [ "$VOLUME" -eq 0 ]; then
            echo "Mute"
        elif [ "$VOLUME" -lt 30 ]; then
            echo "+"
        elif [ "$VOLUME" -lt 70 ]; then
            echo "++"
        else
            echo "+++"
        fi
    }

    case "''${1:-}" in
        up)
            pulsemixer --change-volume +5
            ;;
        down)
            pulsemixer --change-volume -5
            ;;
        mute)
            pulsemixer --toggle-mute
            ;;
        *)
            ICON=$(get_volume_icon)
            if [ "$MUTED" = "1" ]; then
                echo "$ICON MUT"
            else
                echo "$ICON $VOLUME%"
            fi
            ;;
    esac
  '';
  executable = true;
};






# Next wallpaper
home.file.".config/scripts/wallpaper-next.sh" = {
  text = ''
    #!/bin/sh
    DIR="$HOME/Pictures/wallpapers"
    LIST=$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort)
    CURRENT=$(cat "$HOME/.current-wallpaper" 2>/dev/null)

    mapfile -t FILES <<EOF
$LIST
EOF

    for i in "''${!FILES[@]}"; do
        [ "''${FILES[$i]}" = "$CURRENT" ] && INDEX=$i && break
    done

    NEXT_INDEX=$(( (INDEX + 1) % ''${#FILES[@]} ))
    NEXT="''${FILES[$NEXT_INDEX]}"

    feh --no-fehbg --bg-fill "$NEXT"
    echo "$NEXT" > "$HOME/.current-wallpaper"
  '';
  executable = true;
};

# Previous wallpaper
home.file.".config/scripts/wallpaper-prev.sh" = {
  text = ''
    #!/bin/sh
    DIR="$HOME/Pictures/wallpapers"
    LIST=$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort)
    CURRENT=$(cat "$HOME/.current-wallpaper" 2>/dev/null)

    mapfile -t FILES <<EOF
$LIST
EOF

    for i in "''${!FILES[@]}"; do
        [ "''${FILES[$i]}" = "$CURRENT" ] && INDEX=$i && break
    done

    PREV_INDEX=$(( (INDEX - 1 + ''${#FILES[@]}) % ''${#FILES[@]} ))
    PREV="''${FILES[$PREV_INDEX]}"

    feh --no-fehbg --bg-fill "$PREV"
    echo "$PREV" > "$HOME/.current-wallpaper"
  '';
  executable = true;
};

# Random wallpaper
home.file.".config/scripts/wallpaper-random.sh" = {
  text = ''
    #!/bin/sh
    DIR="$HOME/Pictures/wallpapers"
    WALL=$(find "$DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | shuf -n1)

    [ -n "$WALL" ] && feh --no-fehbg --bg-fill "$WALL" && echo "$WALL" > "$HOME/.current-wallpaper"
  '';
  executable = true;
};


