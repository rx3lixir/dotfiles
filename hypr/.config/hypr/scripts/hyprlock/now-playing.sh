#!/bin/sh

# Get the max length from arguments (default 50)
MAX_LENGTH=50
for arg in "$@"; do
    case $arg in
        max_length=*)
            MAX_LENGTH="${arg#*=}"
            ;;
    esac
done

# Check if anything is playing
if ! playerctl status >/dev/null 2>&1; then
    echo ""
    exit 0
fi

# Get metadata
player=$(playerctl -l 2>/dev/null | head -n1)
title=$(playerctl metadata xesam:title 2>/dev/null)
artist=$(playerctl metadata xesam:artist 2>/dev/null)
url=$(playerctl metadata xesam:url 2>/dev/null)

# If no title, nothing to show
if [ -z "$title" ]; then
    echo ""
    exit 0
fi

# Format based on source
case "$player" in
    *spotify*)
        if [ -n "$artist" ]; then
            output="  Spotify: $title - $artist"
        else
            output="  Spotify: $title"
        fi
        ;;
    *firefox*|*chromium*|*chrome*)
        # Check if it's YouTube
        if echo "$url" | grep -q "youtube.com"; then
            output="  YouTube: $title"
        else
            output="  Browser: $title"
        fi
        ;;
    *)
        # Generic format for other players
        if [ -n "$artist" ]; then
            output="$title - $artist"
        else
            output="$title"
        fi
        ;;
esac

# Truncate if too long
if [ ${#output} -gt "$MAX_LENGTH" ]; then
    output=$(echo "$output" | cut -c1-$((MAX_LENGTH - 3)))...
fi

echo "$output"
