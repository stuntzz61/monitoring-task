#!/bin/bash

echo "$(date '+%Y-%m-%d %H:%M:%S') test_monitor.sh started" >> /var/log/monitoring.log

PROCESS_NAME="test"
API_URL="https://test.com/monitoring/test/api"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="/tmp/test_monitor.pid"

CURRENT_PID=$(pgrep -o "$PROCESS_NAME")

if [[ -z "$CURRENT_PID" ]]; then
    exit 0
fi


if [[ -f "$PID_FILE" ]]; then
    LAST_PID=$(cat "$PID_FILE")
    if [[ "$CURRENT_PID" != "$LAST_PID" ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') Process $PROCESS_NAME restarted (old PID: $LAST_PID, new PID: $CURRENT_PID)" >> "$LOG_FILE"
        # logger -t test_monitor "Process restarted: $LAST_PID → $CURRENT_PID"
    fi
fi


echo "$CURRENT_PID" > "$PID_FILE"
JSON_PAYLOAD=$(jq -n \
  --arg status "ok" \
  --arg pid "$CURRENT_PID" \
  --arg time "$(date -Iseconds)" \
  '{proc_status: $status, pid: $pid, timestamp: $time}')


HTTP_CODE=$(curl -fsSkL -o /dev/null -w "%{http_code}" -X POST "$API_URL" \
  -H "Content-Type: application/json" \
  -d "$JSON_PAYLOAD")


if [[ ! "$HTTP_CODE" =~ ^2|^3 ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') Monitoring failed (HTTP $HTTP_CODE) at $API_URL" >> "$LOG_FILE"
    # logger -t test_monitor "Monitoring failed (HTTP $HTTP_CODE)"
fi

# Удаляем старые строки, если лог больше 20 строк
MAX_LINES=20
LINE_COUNT=$(wc -l < "$LOG_FILE")

if (( LINE_COUNT > MAX_LINES )); then
    tail -n "$MAX_LINES" "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
fi


exit 0


#закомментированая функция "logger" болеее удобная альтернитива записи логов с просмотром через "journalctl". 
# в скрипте оставлена запись логов в файл, строго по ТЗ
