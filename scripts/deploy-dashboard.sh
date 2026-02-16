#!/bin/bash
# Script para deploy do Dashboard Atlas HQ

DASHBOARD_DIR="/home/moltuser/.openclaw/workspace/dashboard"
PID_FILE="/tmp/dashboard.pid"
PORT=8080

echo "🦞 Iniciando dashboard do Atlas HQ..."

# Matar processo anterior se existir
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p $OLD_PID > /dev/null 2>&1; then
        echo "🛑 Parando processo anterior (PID: $OLD_PID)..."
        kill $OLD_PID
        sleep 2
    fi
fi

# Matar qualquer processo que esteja usando a porta 8080
pkill -f "python.*$PORT" 2>/dev/null
fuser -k 8080/tcp 2>/dev/null

cd "$DASHBOARD_DIR"

# Iniciar servidor web simples em background
echo "🚀 Iniciando servidor na porta $PORT..."

nohup python3 -m http.server $PORT > /tmp/dashboard.log 2>&1 &
PID=$!

echo $PID > "$PID_FILE"

sleep 2

# Verificar se iniciou
if ps -p $PID > /dev/null; then
    echo "✅ Dashboard iniciado com sucesso (PID: $PID)"
    echo "📱 Acesso: http://100.110.196.39:$PORT/"
    echo "📊 Tailscale: http://zen-grid:$PORT/"
else
    echo "❌ Falha ao iniciar dashboard"
    tail -20 /tmp/dashboard.log
    exit 1
fi
