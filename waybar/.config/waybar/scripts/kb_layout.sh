#!/usr/bin/env bash
# Waybar custom module script: show current keyboard layout in Hyprland
# Works even with multiple keyboards (like kanata, laptop kb, etc.)
# It scans all keyboards and picks the *active* one
# that differs from the default "English (US)" layout.

# Get all current keymaps
layouts=$(hyprctl -j devices | jq -r '.keyboards[]?.active_keymap' | grep -v null)

# Prefer a non-English layout if one exists
if echo "$layouts" | grep -q "Russian"; then
  current="Russian"
elif echo "$layouts" | grep -q "English"; then
  current="English (US)"
else
  current="Unknown"
fi

# Convert to short two-letter code
case "$current" in
  *"English"*) lang="English(US)" ;;
  *"Russian"*) lang="Русский" ;;
  *) lang="??" ;;
esac

# Output JSON for Waybar
printf '{"text":"%s","tooltip":"%s"}\n' "$lang" "$current"
