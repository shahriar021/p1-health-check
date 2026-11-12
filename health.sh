#!/bin/bash
TARGET="${1:-/}"
echo "=== Health Check: $(date) ==="
echo "User: $(whoami)"
echo "--- Disk ($TARGET) ---"
DISK=$(df -h "$TARGET" | tail -1 | awk '{print $5}' | tr -d '%')

if [ -z "$DISK" ]; then
  echo "ERROR: could not read disk usage"
  exit 1
fi

echo "Disk used: $DISK%"
if [ "$DISK" -gt 80 ]; then
  echo "WARNING: disk is above 80%"
else
  echo "OK: disk is healthy"
fi

echo "--- Uptime ---"
uptime