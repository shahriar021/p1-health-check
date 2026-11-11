#!/bin/bash
echo "=== Health Check: $(date) ==="
echo "User: $(whoami)"
echo "--- Disk ---"
df -h | grep "Data$"
echo "--- Uptime ---"
uptime