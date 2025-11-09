#!/usr/bin/env bash

# Tofi Main Menu
# A simple launcher menu for various tofi modes

SCRIPT_DIR="$HOME/.config/tofi/scripts"

# Define menu options and their commands
# Format: "Display Name|Command to execute"
menu_items=(
    "󰀻 Applications|tofi-drun --drun-launch=true --font 'Ubuntu Nerd Font' --prompt-text '> Run: '"
    "󰸉 Wallpapers|$SCRIPT_DIR/wallpaper-picker.sh"
    " Emojis|$SCRIPT_DIR/emoji-picker.sh"
    " Themes|$SCRIPT_DIR/theme-switcher.sh"
    "󰂯 Bluetooth|$SCRIPT_DIR/apps/launch-bluetui.sh"
    "󰤥 Wifi|$SCRIPT_DIR/apps/launch-impala.sh"
    "󱡫 Audio|$SCRIPT_DIR/apps/launch-wiremix.sh"
    " Files|$SCRIPT_DIR/apps/launch-yazi.sh"
    " System monitor|$SCRIPT_DIR/apps/launch-btop.sh"
    "⏻ Power|$SCRIPT_DIR/apps/launch-wlogout.sh"
    "󰗊 Translate|$SCRIPT_DIR/apps/launch-translate.sh"
)

# Extract display names for tofi
display_names=()
for item in "${menu_items[@]}"; do
    display_names+=("${item%%|*}")
done

# Show menu in tofi
selected=$(printf '%s\n' "${display_names[@]}" | tofi \
    --font "Ubuntu Nerd Font" \
    --prompt-text "󰍉 Menu: ")

# Exit if nothing selected
if [[ -z "$selected" ]]; then
    exit 0
fi

# Find and execute the corresponding command
for item in "${menu_items[@]}"; do
    display_name="${item%%|*}"
    command="${item#*|}"
    
    if [[ "$display_name" == "$selected" ]]; then
        eval "$command"
        exit 0
    fi
done

# If we got here, something went wrong
notify-send "Tofi Menu" "Could not find command for: $selected" -u critical
exit 1
