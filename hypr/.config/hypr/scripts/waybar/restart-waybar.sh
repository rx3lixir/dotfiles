#!/bin/bash

echo "Restarting waybar and swaync..."

# Kill waybar
if pgrep -x waybar > /dev/null; then
    killall waybar
    echo "✓ Killed waybar"
else
    echo "⚠ Waybar wasn't running"
fi

# Kill swaync (kills both daemon and client)
if pgrep -x swaync > /dev/null; then
    killall swaync
    echo "✓ Killed swaync"
else
    echo "⚠ Swaync wasn't running"
fi

# Kill swayosd (kills both daemon and client)
if pgrep -x swayosd-server > /dev/null; then
    killall swayosd-server 
    echo "✓ Killed swayosd"
else
    echo "⚠ Swayosd wasn't running"
fi

# Give them a moment to fully close
sleep 0.5

# Start them fresh
waybar &
echo "✓ Started waybar"

swaync &
echo "✓ Started swaync"

swayosd-server &
echo "✓ Started swayosd"

echo "All done! Check your bar for changes."
