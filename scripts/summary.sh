#!/bin/bash

# summary.sh - Otimização de Gateway
# Gera um resumo técnico rápido sem LLM

OUTPUT="/home/moltuser/.openclaw/logs/status_summary.txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

{
    echo "Last Check: $DATE"
    echo "Disk Usage: $(df -h / | tail -1 | awk '{print $5}')"
    echo "Memory Used: $(free -h | grep Mem | awk '{print $3}')"
    echo "Load Average: $(cat /proc/loadavg | awk '{print $1, $2, $3}')"
    echo "Uptime: $(uptime -p)"
} > "$OUTPUT"
