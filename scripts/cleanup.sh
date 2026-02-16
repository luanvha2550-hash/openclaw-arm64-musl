#!/bin/bash

# cleanup.sh - Otimização de Gateway
# Limpeza de arquivos temporários e logs antigos sem uso de LLM

LOG_FILE="/home/moltuser/.openclaw/logs/cleanup.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$DATE] Iniciando limpeza automática..." >> $LOG_FILE

# 1. Limpar /tmp/ (arquivos com mais de 7 dias)
find /tmp -type f -atime +7 -delete
echo "[$DATE] /tmp/ limpo (arquivos > 7 dias removidos)" >> $LOG_FILE

# 2. Limpar logs do OpenClaw (mais de 30 dias)
OPENCLAW_LOGS="/home/moltuser/.openclaw/logs"
if [ -d "$OPENCLAW_LOGS" ]; then
    find "$OPENCLAW_LOGS" -type f -name "*.log" -mtime +30 -delete
    echo "[$DATE] Logs antigos removidos em $OPENCLAW_LOGS" >> $LOG_FILE
fi

echo "[$DATE] Limpeza concluída." >> $LOG_FILE
