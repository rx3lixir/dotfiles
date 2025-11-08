#!/bin/bash

# Debug log file
LOG="/tmp/waybar_weather.log"
echo "$(date): Starting weather fetch" >> "$LOG"

# Fetch weather for Barnaul with timeout (15 seconds should be enough)
weather_data=$(curl -s --max-time 15 "wttr.in/Barnaul?format=j1" 2>>"$LOG")
curl_exit=$?

echo "$(date): Curl exit code: $curl_exit" >> "$LOG"
echo "$(date): Weather data length: ${#weather_data}" >> "$LOG"

# Check if we have data (even if curl timed out, we might have received it)
if [ -z "$weather_data" ]; then
    echo "$(date): No data received" >> "$LOG"
    echo '{"text":"N/A","tooltip":"Weather data unavailable","class":"error"}'
    exit 0
fi

# Parse JSON with jq - much cleaner!
temp=$(echo "$weather_data" | jq -r '.current_condition[0].temp_C' 2>/dev/null)
condition=$(echo "$weather_data" | jq -r '.current_condition[0].weatherDesc[0].value' 2>/dev/null)
feels_like=$(echo "$weather_data" | jq -r '.current_condition[0].FeelsLikeC' 2>/dev/null)
humidity=$(echo "$weather_data" | jq -r '.current_condition[0].humidity' 2>/dev/null)
wind_speed=$(echo "$weather_data" | jq -r '.current_condition[0].windspeedKmph' 2>/dev/null)
wind_dir=$(echo "$weather_data" | jq -r '.current_condition[0].winddir16Point' 2>/dev/null)

# Check if we got valid data
if [ "$temp" = "null" ] || [ -z "$temp" ]; then
    # echo "$(date): Failed to parse weather data" >> "$LOG"
    echo '{"text":"N/A","tooltip":"Failed to parse weather data","class":"error"}'
    exit 0
fi

# Determine weather icon class based on condition
icon="default"
condition_lower=$(echo "$condition" | tr '[:upper:]' '[:lower:]')

if echo "$condition_lower" | grep -qi "sunny\|clear"; then
    icon="sunny"
elif echo "$condition_lower" | grep -qi "cloud\|overcast\|fog\|mist"; then
    icon="cloudy"
elif echo "$condition_lower" | grep -qi "rain\|drizzle\|shower"; then
    icon="rainy"
elif echo "$condition_lower" | grep -qi "snow\|sleet\|blizzard"; then
    icon="snowy"
fi

# Output JSON format for waybar
jq -n \
    --arg text "${temp}°C" \
    --arg tooltip "Barnaul Weather\n${condition}\nFeels like: ${feels_like}°C\nHumidity: ${humidity}%\nWind: ${wind_speed} km/h ${wind_dir}" \
    --arg class "$icon" \
    '{text: $text, tooltip: $tooltip, class: $class}'

# echo "$(date): Successfully output weather data" >> "$LOG"
