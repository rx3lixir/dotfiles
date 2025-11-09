#!/usr/bin/env bash

# Theme Switcher - Simple, Unix-philosophy theme management
# Switches between static themes and dynamic matugen themes

set -euo pipefail

# Configuration
THEMES_DIR="$HOME/.config/themes"
CURRENT_THEME_FILE="$THEMES_DIR/.current"
HYPRPAPER_CONF="$HOME/.config/hypr/hyprpaper.conf"
RESTART_SCRIPT="$HOME/.config/hypr/scripts/system/restart-graph-env.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check dependencies
check_dependencies() {
    local missing=()
    
    command -v tofi >/dev/null 2>&1 || missing+=("tofi")
    command -v matugen >/dev/null 2>&1 || missing+=("matugen")
    command -v notify-send >/dev/null 2>&1 || missing+=("notify-send")
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing dependencies: ${missing[*]}${NC}" >&2
        exit 1
    fi
}

# Get currently active theme
get_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        cat "$CURRENT_THEME_FILE"
    else
        echo ""
    fi
}

# Get list of available themes
get_available_themes() {
    local themes=()
    
    # Add hardcoded Matugen theme
    themes+=("Matugen")
    
    # Scan for theme.conf files
    if [ -d "$THEMES_DIR" ]; then
        while IFS= read -r theme_conf; do
            local theme_dir=$(dirname "$theme_conf")
            local theme_name=$(parse_theme_name "$theme_conf")
            if [ -n "$theme_name" ]; then
                themes+=("$theme_name")
            fi
        done < <(find -L "$THEMES_DIR" -maxdepth 2 -name "theme.conf" -type f)
    fi
    
    printf '%s\n' "${themes[@]}"
}

# Parse theme name from theme.conf
parse_theme_name() {
    local conf_file="$1"
    grep -E "^name[[:space:]]*=" "$conf_file" | head -1 | sed -E 's/^name[[:space:]]*=[[:space:]]*//' | tr -d '"' | xargs
}

# Get theme directory by name
get_theme_dir() {
    local theme_name="$1"
    
    while IFS= read -r theme_conf; do
        local conf_theme_name=$(parse_theme_name "$theme_conf")
        if [ "$conf_theme_name" = "$theme_name" ]; then
            dirname "$theme_conf"
            return 0
        fi
    done < <(find -L "$THEMES_DIR" -maxdepth 2 -name "theme.conf" -type f)
    
    return 1
}

# Reload graphical environment (waybar, swaync, swayosd)
reload_environment() {
    echo -e "${YELLOW}Reloading graphical environment...${NC}"
    
    # Check if restart script exists
    if [ ! -f "$RESTART_SCRIPT" ]; then
        echo -e "${YELLOW}Warning: Restart script not found at $RESTART_SCRIPT${NC}" >&2
        echo -e "${YELLOW}Skipping environment reload${NC}" >&2
        return 1
    fi
    
    # Check if script is executable
    if [ ! -x "$RESTART_SCRIPT" ]; then
        echo -e "${YELLOW}Warning: Restart script is not executable${NC}" >&2
        echo -e "${YELLOW}Attempting to make it executable...${NC}"
        chmod +x "$RESTART_SCRIPT" || {
            echo -e "${RED}Failed to make script executable${NC}" >&2
            return 1
        }
    fi
    
    # Execute the restart script
    if "$RESTART_SCRIPT"; then
        echo -e "${GREEN}✓ Environment reloaded successfully${NC}"
        notify-send -u normal "Theme Switcher" "Reloading waybar, swaync, and swayosd..."
        return 0
    else
        echo -e "${RED}Warning: Environment reload script failed${NC}" >&2
        return 1
    fi
}

# Apply matugen theme
apply_matugen() {
    echo -e "${GREEN}Applying Matugen theme...${NC}"
    
    # Extract wallpaper path from hyprpaper.conf
    if [ ! -f "$HYPRPAPER_CONF" ]; then
        echo -e "${RED}Error: hyprpaper.conf not found at $HYPRPAPER_CONF${NC}" >&2
        return 1
    fi
    
    local wallpaper=$(grep -E "^wallpaper[[:space:]]*=" "$HYPRPAPER_CONF" | head -1 | sed -E 's/^wallpaper[[:space:]]*=[[:space:]]*,[[:space:]]*//' | xargs)
    
    if [ -z "$wallpaper" ]; then
        echo -e "${RED}Error: Could not extract wallpaper path from hyprpaper.conf${NC}" >&2
        return 1
    fi
    
    if [ ! -f "$wallpaper" ]; then
        echo -e "${RED}Error: Wallpaper file not found: $wallpaper${NC}" >&2
        return 1
    fi
    
    echo -e "${GREEN}Using wallpaper: $wallpaper${NC}"
    
    # Run matugen
    if matugen image "$wallpaper"; then
        echo -e "${GREEN}Matugen applied successfully!${NC}"
        echo "Matugen" > "$CURRENT_THEME_FILE"
        notify-send -u normal "Theme Switcher" "Matugen theme applied"
        
        # Give notification time to display before restarting notification daemon
        sleep 1.5
        
        # Reload environment
        reload_environment
        
        return 0
    else
        echo -e "${RED}Error: matugen command failed${NC}" >&2
        return 1
    fi
}

# Apply static theme
apply_static_theme() {
    local theme_name="$1"
    local theme_dir=$(get_theme_dir "$theme_name")
    
    if [ -z "$theme_dir" ]; then
        echo -e "${RED}Error: Could not find theme directory for '$theme_name'${NC}" >&2
        return 1
    fi
    
    local theme_conf="$theme_dir/theme.conf"
    
    echo -e "${GREEN}Applying theme: $theme_name${NC}"
    
    # Parse and copy files
    local errors=0
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ $line =~ ^[[:space:]]*# ]] && continue
        [[ -z $line ]] && continue
        [[ $line =~ ^name[[:space:]]*= ]] && continue
        
        # Parse source -> destination
        if [[ $line =~ ^(.+)[[:space:]]*-\>[[:space:]]*(.+)$ ]]; then
            local src="${BASH_REMATCH[1]}"
            local dst="${BASH_REMATCH[2]}"
            
            # Trim whitespace
            src=$(echo "$src" | xargs)
            dst=$(echo "$dst" | xargs)
            
            # Expand tilde in destination
            dst="${dst/#\~/$HOME}"
            
            # Full source path
            local src_path="$theme_dir/$src"
            
            # Check source exists
            if [ ! -f "$src_path" ]; then
                echo -e "${YELLOW}Warning: Source file not found: $src_path${NC}" >&2
                ((errors++))
                continue
            fi
            
            # Check destination directory exists
            local dst_dir=$(dirname "$dst")
            if [ ! -d "$dst_dir" ]; then
                echo -e "${YELLOW}Warning: Destination directory does not exist: $dst_dir${NC}" >&2
                ((errors++))
                continue
            fi
            
            # Copy file
            if cp "$src_path" "$dst"; then
                echo -e "${GREEN}✓${NC} Copied: $src -> $dst"
            else
                echo -e "${RED}✗${NC} Failed to copy: $src -> $dst" >&2
                ((errors++))
            fi
        fi
    done < "$theme_conf"
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}Theme '$theme_name' applied successfully!${NC}"
        echo "$theme_name" > "$CURRENT_THEME_FILE"
        notify-send -u normal "Theme Switcher" "Theme '$theme_name' applied"
        
        # Give notification time to display before restarting notification daemon
        sleep 1.5
        
        # Reload environment
        reload_environment
        
        return 0
    else
        echo -e "${YELLOW}Theme applied with $errors warning(s)${NC}"
        echo "$theme_name" > "$CURRENT_THEME_FILE"
        notify-send -u normal "Theme Switcher" "Theme '$theme_name' applied with warnings"
        
        # Give notification time to display before restarting notification daemon
        sleep 1.5
        
        # Reload environment even with warnings
        reload_environment
        
        return 0
    fi
}

# Show theme menu and apply selection
show_menu() {
    local current_theme=$(get_current_theme)
    local themes=()
    
    # Build menu with checkmarks
    while IFS= read -r theme; do
        if [ "$theme" = "$current_theme" ]; then
            themes+=("$theme ✓")
        else
            themes+=("$theme")
        fi
    done < <(get_available_themes)
    
    if [ ${#themes[@]} -eq 0 ]; then
        echo -e "${RED}Error: No themes found${NC}" >&2
        exit 1
    fi
    
    # Show tofi menu
    local selected=$(printf '%s\n' "${themes[@]}" | tofi --prompt-text " Themes: ")
    
    if [ -z "$selected" ]; then
        echo "No theme selected, exiting."
        exit 0
    fi
    
    # Remove checkmark if present
    selected="${selected% ✓}"
    
    # Apply theme
    if [ "$selected" = "Matugen" ]; then
        apply_matugen
    else
        apply_static_theme "$selected"
    fi
}

# Main
main() {
    check_dependencies
    
    # Create themes directory if it doesn't exist
    mkdir -p "$THEMES_DIR"
    
    show_menu
}

main "$@"
