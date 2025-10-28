#!/usr/bin/env bash

# Tofi Clipboard History Picker
# Browse clipboard history and copy selected item back to clipboard

# Maximum number of items to show
MAX_ITEMS=20

# Check if cliphist is available
if ! command -v cliphist &> /dev/null; then
    echo "Error: cliphist is not installed"
    echo "Please install cliphist package"
    exit 1
fi

# Check if wl-copy is available
if ! command -v wl-copy &> /dev/null; then
    echo "Error: wl-copy is not installed"
    echo "Please install wl-clipboard package"
    exit 1
fi

# Get clipboard history (limited to MAX_ITEMS)
# We'll store the full lines and create truncated display versions
mapfile -t full_lines < <(cliphist list | head -n "$MAX_ITEMS")

# Create truncated display version
display_lines=()
for line in "${full_lines[@]}"; do
    if [[ ${#line} -gt 30 ]]; then
        display_lines+=("${line:0:30}...")
    else
        display_lines+=("$line")
    fi
done

# Show truncated version in tofi
selected_display=$(printf '%s\n' "${display_lines[@]}" | tofi \
    --font "Ubuntu Nerd Font, Apple Color Emoji" \
    --prompt-text " Clipboard: ")

# Exit if nothing was selected (user pressed Escape)
if [[ -z "$selected_display" ]]; then
    exit 0
fi

# Find the index of selected item
selected_index=-1
for i in "${!display_lines[@]}"; do
    if [[ "${display_lines[$i]}" == "$selected_display" ]]; then
        selected_index=$i
        break
    fi
done

# Get the original full line using the index
if [[ $selected_index -ge 0 ]]; then
    selected="${full_lines[$selected_index]}"
else
    exit 1
fi

# Decode and copy the selected item back to clipboard
# cliphist decode takes the full line and extracts the actual content
echo "$selected" | cliphist decode | wl-copy

exit 0
