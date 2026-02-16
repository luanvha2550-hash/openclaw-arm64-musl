#!/bin/bash

# logrotate.sh - Otimização de Gateway
# Rotação e compressão de logs sem uso de LLM

LOG_DIR="/home/moltuser/.openclaw/logs"
BACKUP_DIR="/home/moltuser/.openclaw/logs/archive"
DATE=$(date "+%Y-%m-%d_%H-%M-%S")
ROTATE_LOG="/home/moltuser/.openclaw/logs/logrotate.log"

mkdir -p "$BACKUP_DIR"

echo "[$(date "+%Y-%m-%d %H:%M:%S")] Iniciando rotação de logs..." >> "$ROTATE_LOG"

# Rotacionar logs maiores que 5MB (5242880 bytes)
find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" -size +5242880c | while read -r log_file; do
    filename=$(basename "$log_file")
    echo "[$(date "+%Y-%m-%d %H:%M:%S")] Rotacionando $filename..." >> "$ROTATE_LOG"
    mv "$log_file" "$BACKUP_DIR/${filename}.$DATE"
    gzip "$BACKUP_DIR/${filename}.$DATE"
done

# Manter apenas os últimos 10 logs arquivados
if [ "$(ls -A "$BACKUP_DIR")" ]; then
    ls -dt "$BACKUP_DIR"/* | tail -n +11 | xargs -r rm
fi
echo "[$(date "+%Y-%m-%d %H:%M:%S")] Rotação concluída. Arquivo de backup limpo (mantidos os 10 mais recentes)." >> "$ROTATE_LOG"
