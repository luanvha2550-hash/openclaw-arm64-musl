#!/bin/bash
# Disk Monitor Script - Sem LLM, economia de tokens
# Verifica espaço em disco e alerta se estiver crítico

THRESHOLD=80
LOG_FILE="/tmp/disk-monitor.log"
ALERT_FILE="/tmp/disk-alert-sent"

# Limpa log antigo
> "$LOG_FILE"

echo "=== Disk Monitor - $(date) ===" >> "$LOG_FILE"

# Verifica espaço em disco
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "Root usage: ${DISK_USAGE}%" >> "$LOG_FILE"

# Verifica se tem SD card montado
if [ -d "/mnt/sdcard" ] || [ -d "/storage/sdcard" ]; then
    SD_MOUNT=$(mount | grep -E "(sdcard|mmcblk)" | head -1)
    if [ -n "$SD_MOUNT" ]; then
        SD_PATH=$(echo "$SD_MOUNT" | awk '{print $3}')
        SD_USAGE=$(df -h "$SD_PATH" 2>/dev/null | awk 'NR==2 {print $5}' | tr -d '%')
        echo "SD Card ($SD_PATH): ${SD_USAGE}%" >> "$LOG_FILE"
    fi
fi

# Alerta se passar do threshold
if [ "$DISK_USAGE" -gt "$THRESHOLD" ]; then
    if [ ! -f "$ALERT_FILE" ]; then
        echo "ALERTA: Espaço em disco crítico! ${DISK_USAGE}% usado." >> "$LOG_FILE"
        # Cria arquivo de alerta para não repetir
        echo "1" > "$ALERT_FILE"
        exit 1  # Código de erro para o cron saber que precisa alertar
    fi
else
    # Remove alerta se espaço normalizar
    rm -f "$ALERT_FILE"
fi

echo "OK: Espaço em disco normal" >> "$LOG_FILE"
exit 0
