#!/bin/bash
echo "=== Health Check: $(date) ==="
echo "User: $(whoami)"
echo "--- Disk ---"

DISK=$(df -h | grep "Data$" | awk '{print $5}' | tr -d '%')
echo "Disk used: $DISK%"

if [ "$DISK"  -gt 80 ]; then
       echo "WARNING: disk is above 80%"
else
  echo "OK: disk is healthy"
fi

echo "--- Uptime ---"
uptime