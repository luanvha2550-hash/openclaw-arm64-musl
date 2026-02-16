#!/bin/bash
# Script para garantir que o dashboard esteja sempre rodando

PID_FILE="/tmp/dashboard.pid"
PORT=8080

# Verificar se o processo está rodando
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "✅ Dashboard rodando (PID: $PID)"
        exit 0
    fi
fi

# Se não está rodando, inicia
echo "🔄 Dashboard não encontrado, reiniciando..."
/home/moltuser/.openclaw/workspace/scripts/deploy-dashboard.sh > /dev/null 2>&1
