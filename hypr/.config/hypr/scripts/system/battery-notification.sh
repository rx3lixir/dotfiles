#!/bin/bash

# Battery notification script for Hyprland with swaync
# Monitors battery level and charging status

# Paths to battery information
BATTERY="/sys/class/power_supply/BAT0"
AC_ADAPTER="/sys/class/power_supply/ACAD"

# Get current battery percentage
get_battery_level() {
    cat "$BATTERY/capacity"
}

# Check if AC adapter is plugged in (1 = plugged, 0 = unplugged)
is_plugged() {
    cat "$AC_ADAPTER/online"
}

# Send notification with appropriate urgency
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"  # low, normal, or critical
    local icon="$4"
    
    notify-send -u "$urgency" -i "$icon" "$title" "$message"
}

# Main monitoring function
monitor_battery() {
    local battery_level
    local plugged_in
    
    battery_level=$(get_battery_level)
    plugged_in=$(is_plugged)
    
    # Check if fully charged while plugged in
    if [ "$plugged_in" -eq 1 ] && [ "$battery_level" -eq 100 ]; then
        send_notification \
            "Battery Fully Charged" \
            "Battery is at 100%. You can unplug your charger." \
            "normal" \
            "battery-full-charged"
    fi
    
    # Check battery levels when unplugged
    if [ "$plugged_in" -eq 0 ]; then
        case "$battery_level" in
            20)
                send_notification \
                    "Battery Low" \
                    "Battery is at 20%. Consider plugging in soon." \
                    "normal" \
                    "battery-low"
                ;;
            10)
                send_notification \
                    "Battery Critical" \
                    "Battery is at 10%! Plug in your charger now." \
                    "critical" \
                    "battery-caution"
                ;;
            5)
                send_notification \
                    "Battery Critical" \
                    "Battery is at 5%! System will shut down soon!" \
                    "critical" \
                    "battery-empty"
                ;;
        esac
    fi
}

# Run the monitoring function
monitor_battery
