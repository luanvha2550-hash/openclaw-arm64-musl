#!/bin/bash

# healthcheck.sh - Otimização de Gateway
# Monitoramento básico de recursos sem uso de LLM

REPORT_FILE="/home/moltuser/.openclaw/logs/healthcheck.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

{
    echo "--- HEALTH REPORT [$DATE] ---"
    echo "Uptime: $(uptime)"
    echo "Memory: $(free -h | grep Mem)"
    echo "Disk: $(df -h / | tail -1)"
    echo "Load: $(cat /proc/loadavg)"
    echo "------------------------------"
} >> "$REPORT_FILE"
