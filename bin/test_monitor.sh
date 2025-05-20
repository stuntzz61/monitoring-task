#!/bin/bash

PROCESS_NAME="test"
API_URL="https://test.com/monitoring/test/api"
LOG_FILE="/home/stuntzz/monitoring-task/log/monitoring.log"
PID_FILE="$(dirname "$LOG_FILE")/test_monitor.pid"

CURRENT_PID=$(pgrep -o "$PROCESS_NAME")

if [[ -z "$CURRENT_PID" ]]; then
    exit 0
fi

if [[ -f "$PID_FILE" ]]; then
    LAST_PID=$(cat "$PID_FILE")
    if [[ "$CURRENT_PID" != "$LAST_PID" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Process $PROCESS_NAME restarted (old PID: $LAST_PID, new PID: $CURRENT_PID)" >> "$LOG_FILE"
    fi
fi

echo "$CURRENT_PID" > "$PID_FILE"

curl -fsS --max-time 5 "$API_URL" > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Failed to reach monitoring server at $API_URL" >> "$LOG_FILE"
fi

exit 0
