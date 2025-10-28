#!/usr/bin/env bash

# Tofi Emoji Picker
# Simple emoji picker that copies selected emoji to clipboard

# Path to emoji list file
EMOJI_FILE="$HOME/.config/tofi/emojis/emoji-list.txt"

# Check if emoji file exists
if [[ ! -f "$EMOJI_FILE" ]]; then
    echo "Error: Emoji list not found at $EMOJI_FILE"
    echo "Please create the file with format: 'emoji description' (one per line)"
    exit 1
fi

# Check if wl-copy is available
if ! command -v wl-copy &> /dev/null; then
    echo "Error: wl-copy is not installed"
    echo "Please install wl-clipboard package"
    exit 1
fi

# Launch tofi with the emoji list
# Using --font from config and additional performance args
selected=$(cat "$EMOJI_FILE" | tofi \
    --font "Ubuntu Nerd Font" \
    --prompt-text " Emoji: ")

# Exit if nothing was selected (user pressed Escape)
if [[ -z "$selected" ]]; then
    exit 0
fi

# Extract just the emoji (first field before the space)
emoji=$(echo "$selected" | awk '{print $1}')

# Copy emoji to clipboard
echo -n "$emoji" | wl-copy

# Show notification that emoji was copied
notify-send "Emoji Copied" "$emoji"

exit 0
