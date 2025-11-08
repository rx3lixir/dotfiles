#!/bin/bash
PID_FILE="/tmp/wl-recorder.pid"
RECORD_DIR="$HOME/Videos/Recordings"
mkdir -p "$RECORD_DIR"

# Check if already recording
if [ -f "$PID_FILE" ]; then
    # Stop recording
    PID=$(cat "$PID_FILE")
    kill -INT "$PID" 2>/dev/null
    rm "$PID_FILE"
    notify-send -u normal "Screen Recording" "Recording stopped and saved!" -i media-record
    exit 0
fi

# Start recording based on argument
FILENAME="$RECORD_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"

case "$1" in
    audio)
        # Record with audio
        nohup wl-screenrec --audio -f "$FILENAME" > /dev/null 2>&1 &
        ;;
    region)
        # Record selected region
        GEOMETRY=$(slurp)
        if [ -z "$GEOMETRY" ]; then
            notify-send -u normal "Screen Recording" "Region selection cancelled" -i dialog-cancel
            exit 1
        fi
        nohup wl-screenrec -g "$GEOMETRY" -f "$FILENAME" > /dev/null 2>&1 &
        ;;
    *)
        # Default: record full screen
        nohup wl-screenrec -f "$FILENAME" > /dev/null 2>&1 &
        ;;
esac

echo $! > "$PID_FILE"
disown

notify-send -u normal "Screen Recording" "Recording started..." -i media-record
