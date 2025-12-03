#!/bin/bash

# Battery monitoring script using direct sysfs access
BATTERY_LOW=20
BATTERY_CRITICAL=10
CHECK_INTERVAL=60
SOUND_ENABLED=true

# Find battery
find_battery() {
    for bat in /sys/class/power_supply/BAT*; do
        if [ -d "$bat" ] && [ -f "$bat/capacity" ] && [ -f "$bat/status" ]; then
            echo "$bat"
            return 0
        fi
    done
    return 1
}

# Function to play sound
play_sound() {
    if [ "$SOUND_ENABLED" = true ]; then
        # Use pactl (from pipewire-pulse) to play system sound
        pactl play-sample sample-alarm 2>/dev/null || true
    fi
}

# Function to send urgent notification
send_notification() {
    local level="$1"
    local percentage="$2"
    local message="$3"
    
    # Critical urgency ensures notification appears on top
    notify-send -u critical -i battery-low "Battery $level" "$message" -t 10000
    echo "[$(date)] Battery $level: $percentage% - $message" >> /tmp/battery-monitor.log
}

BATTERY_PATH=$(find_battery)

if [ -z "$BATTERY_PATH" ]; then
    echo "Error: No battery found!" >&2
    exit 1
fi

echo "Monitoring battery at $BATTERY_PATH" >> /tmp/battery-monitor.log

# Track notification state
notified_low=false
notified_critical=false

while true; do
    capacity=$(cat "$BATTERY_PATH/capacity" 2>/dev/null)
    status=$(cat "$BATTERY_PATH/status" 2>/dev/null)
    
    if [ -n "$capacity" ] && [ -n "$status" ]; then
        if [ "$status" = "Discharging" ]; then
            if [ "$capacity" -le "$BATTERY_CRITICAL" ]; then
                if [ "$notified_critical" = false ]; then
                    send_notification "CRITICAL" "$capacity" "Battery at ${capacity}%! Connect charger immediately!"
                    play_sound
                    notified_critical=true
                    notified_low=true
                fi
                # Check more frequently when critical
                sleep 30
                continue
            elif [ "$capacity" -le "$BATTERY_LOW" ]; then
                if [ "$notified_low" = false ]; then
                    send_notification "LOW" "$capacity" "Battery at ${capacity}%. Connect charger soon."
                    play_sound
                    notified_low=true
                fi
            else
                # Reset notifications when above thresholds
                notified_low=false
                notified_critical=false
            fi
        else
            # Reset notifications when charging
            notified_low=false
            notified_critical=false
        fi
    fi
    
    sleep $CHECK_INTERVAL
done
