#!/usr/bin/env bash
# Wallpaper picker script for tofi + hyprpaper + hyprlock

WALLPAPER_DIR="$HOME/.config/hypr/wpapers"
HYPRPAPER_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
HYPRLOCK_CONFIG="$HOME/.config/hypr/hyprlock.conf"

# Check if wallpaper directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper Picker" "Wallpaper directory not found: $WALLPAPER_DIR" -u critical
    exit 1
fi

# Check if hyprpaper is running
if ! pgrep -x hyprpaper > /dev/null; then
    notify-send "Wallpaper Picker" "hyprpaper is not running!" -u critical
    exit 1
fi

# Get list of wallpapers (strip extensions for display)
wallpapers=()
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    wallpapers+=("${filename%.*}")
done < <(find -L "$WALLPAPER_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) -print0 | sort -z)

# Check if we found any wallpapers
if [[ ${#wallpapers[@]} -eq 0 ]]; then
    notify-send "Wallpaper Picker" "No wallpapers found in $WALLPAPER_DIR" -u critical
    exit 1
fi

# Show wallpapers in tofi and get selection
selected=$(printf '%s\n' "${wallpapers[@]}" | tofi \
    --font "Ubuntu Nerd Font" \
    --prompt-text "󰸉 Wallpaper: ")

# Exit if nothing selected
if [[ -z "$selected" ]]; then
    exit 0
fi

# Find the actual file with extension
actual_file=""
for file in "$WALLPAPER_DIR/$selected".*; do
    if [[ -f "$file" ]]; then
        actual_file="$file"
        break
    fi
done

if [[ -z "$actual_file" ]]; then
    notify-send "Wallpaper Picker" "Could not find file for: $selected" -u critical
    exit 1
fi

# Preload the new wallpaper
hyprctl hyprpaper preload "$actual_file"

# Set wallpaper on all monitors
hyprctl hyprpaper wallpaper ",$actual_file"

# Update hyprpaper config for persistence
if [[ -f "$HYPRPAPER_CONFIG" ]]; then
    # Create a temporary file
    temp_config=$(mktemp)
    
    # Read the config and update preload and wallpaper lines
    preload_updated=false
    wallpaper_updated=false
    
    while IFS= read -r line; do
        if [[ $line =~ ^[[:space:]]*preload[[:space:]]*= ]]; then
            echo "preload   =   $actual_file" >> "$temp_config"
            preload_updated=true
        elif [[ $line =~ ^[[:space:]]*wallpaper[[:space:]]*= ]]; then
            echo "wallpaper = , $actual_file" >> "$temp_config"
            wallpaper_updated=true
        else
            echo "$line" >> "$temp_config"
        fi
    done < "$HYPRPAPER_CONFIG"
    
    # If preload or wallpaper lines weren't found, add them
    if [[ "$preload_updated" == false ]]; then
        echo "preload   =   $actual_file" >> "$temp_config"
    fi
    if [[ "$wallpaper_updated" == false ]]; then
        echo "wallpaper = , $actual_file" >> "$temp_config"
    fi
    
    # Replace old config with new one
    mv "$temp_config" "$HYPRPAPER_CONFIG"
else
    notify-send "Wallpaper Picker" "Config file not found: $HYPRPAPER_CONFIG" -u critical
    exit 1
fi

# Update hyprlock config for persistence
if [[ -f "$HYPRLOCK_CONFIG" ]]; then
    # Create a temporary file
    temp_lock_config=$(mktemp)
    
    # Read the config and update $wallpaper line
    while IFS= read -r line; do
        if [[ $line =~ ^\$wallpaper[[:space:]]*= ]]; then
            echo "\$wallpaper      = $actual_file" >> "$temp_lock_config"
        else
            echo "$line" >> "$temp_lock_config"
        fi
    done < "$HYPRLOCK_CONFIG"
    
    # Replace old config with new one
    mv "$temp_lock_config" "$HYPRLOCK_CONFIG"
else
    notify-send "Wallpaper Picker" "Config file not found: $HYPRLOCK_CONFIG" -u critical
    exit 1
fi

notify-send "Wallpaper Changed" "Set to: $selected"
