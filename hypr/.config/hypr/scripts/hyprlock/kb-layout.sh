#!/bin/sh

# Get all current keymaps from all keyboards
layouts=$(hyprctl -j devices 2>/dev/null | jq -r '.keyboards[]?.active_keymap' 2>/dev/null | grep -v null)

# If hyprctl or jq failed
if [ -z "$layouts" ]; then
    echo "??"
    exit 0
fi

# Prefer a non-English layout if one exists
if echo "$layouts" | grep -q "Russian"; then
    current="Russian"
elif echo "$layouts" | grep -q "English"; then
    current="English (US)"
else
    current="Unknown"
fi

# Convert to display format
case "$current" in
    *"English"*)
        echo "English(US)"
        ;;
    *"Russian"*)
        echo "Русский"
        ;;
    *)
        echo "??"
        ;;
esac
