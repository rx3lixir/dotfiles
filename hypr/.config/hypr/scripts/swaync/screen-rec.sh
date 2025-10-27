#!/bin/bash

PID_FILE="/tmp/wf-recorder.pid"
RECORD_DIR="$HOME/Videos/Recordings"
mkdir -p "$RECORD_DIR"

if [ -f "$PID_FILE" ]; then
    # Stop recording
    PID=$(cat "$PID_FILE")
    kill -INT "$PID" 2>/dev/null
    rm "$PID_FILE"
    notify-send -u normal "Screen Recording" "Recording stopped and saved!" -i media-record
else
    # Start recording (properly detached)
    FILENAME="$RECORD_DIR/recording_$(date +%Y%m%d_%H%M%S).mp4"
    
    # This is the important part - nohup and redirecting output
    nohup wf-recorder -f "$FILENAME" > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    
    # Disown the process so it's completely independent
    disown
    
    notify-send -u normal "Screen Recording" "Recording started..." -i media-record
fi
