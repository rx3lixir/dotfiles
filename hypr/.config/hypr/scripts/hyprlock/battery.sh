#!/bin/sh

# Battery to monitor (default BAT0)
BATTERY="BAT0"

for arg in "$@"; do
    case $arg in
        battery=*)
            BATTERY="${arg#*=}"
            ;;
    esac
done

BAT_PATH="/sys/class/power_supply/$BATTERY"

# Check if battery exists
if [ ! -d "$BAT_PATH" ]; then
    echo "No battery"
    exit 0
fi

# Get battery percentage
capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null)

# Get charging status
status=$(cat "$BAT_PATH/status" 2>/dev/null)

# If we can't read battery info
if [ -z "$capacity" ]; then
    echo "Battery info unavailable"
    exit 0
fi

# Choose icon based on capacity
if [ "$capacity" -le 10 ]; then
    icon="  "  # Critical
elif [ "$capacity" -le 20 ]; then
    icon="  "  # 10%
elif [ "$capacity" -le 30 ]; then
    icon="  "  # 20%
elif [ "$capacity" -le 40 ]; then
    icon="  "  # 30%
elif [ "$capacity" -le 50 ]; then
    icon="  "  # 40%
elif [ "$capacity" -le 60 ]; then
    icon="  "  # 50%
elif [ "$capacity" -le 70 ]; then
    icon="  "  # 60%
elif [ "$capacity" -le 80 ]; then
    icon="  "  # 70%
elif [ "$capacity" -le 90 ]; then
    icon="  "  # 80%
else
    icon="  "  # 90-100%
fi

# Format output based on charging status
case "$status" in
    Charging)
        echo "󰂄 $capacity%"  # Charging icon
        ;;
    Discharging|"Not charging")
        echo "$icon $capacity%"
        ;;
    Full)
        echo "󰁹 100%"  # Full battery icon
        ;;
    *)
        echo "$icon $capacity%"
        ;;
esac
