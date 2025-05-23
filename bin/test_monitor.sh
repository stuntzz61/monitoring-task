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
     logger -t test_monitor "Failed to reach monitoring server at $API_URL"
    fi
fi

echo "$CURRENT_PID" > "$PID_FILE"

JSON_PAYLOAD=$(jq -n \
  --arg status "ok" \
  --arg pid "$CURRENT_PID" \
  --arg time "$(date -Iseconds)" \
  '{proc_status: $status, pid: $pid, timestamp: $time}')

# Отправляем запрос
curl -fsS --max-time 5 -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD" \
  > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
    logger -t test_monitor "Failed to reach monitoring server at $API_URL"
fi

exit 0
