#!/bin/bash
# health-check-collector.sh
# Coleta todos os dados de sistema health PARA O LLM analisar
# Economiza requisições de API

# Arquivo de cache
CACHE_DIR="/tmp/health-cache"
mkdir -p "$CACHE_DIR"
TIMESTAMP=$(date +%s)
CACHE_FILE="$CACHE_DIR/health-$TIMESTAMP.json"

# Coleta de dados
echo "Collecting system health data..."

# 1. CPU e Memória
cpu_info=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
mem_info=$(free -m | awk 'NR==2{printf "%.1f/%.1fGB (%.1f%% used)", $3/1024, $2/1024, ($3/$2)*100}')

# 2. Disk Space
disk_info=$(df -h / | awk 'NR==2{printf "%s de %s livres (%s usado)", $4, $2, $5}')

# 3. Disk usage por diretório importante
workspace_disk=$(du -sh /home/moltuser/.openclaw/workspace 2>/dev/null | awk '{print $1}')
logs_disk=$(du -sh /home/moltuser/.openclaw/logs 2>/dev/null | awk '{print $1}')

# 4. Sessões inativas
inactive_sessions=$(find /home/moltuser/.openclaw/agents/* -name "*.jsonl" -mtime +1 -type f 2>/dev/null | wc -l)
session_count=$(find /home/moltuser/.openclaw/agents/* -name "*.jsonl" -type f 2>/dev/null | wc -l)

# 5. Logs de erro (última hora)
log_errors=$(find /home/moltuser/.openclaw/logs -name "*.log" -type f -mmin -60 2>/dev/null -exec grep -l "ERROR\|FAIL\|CRITICAL" {} \; | wc -l)
recent_errors=$(find /home/moltuser/.openclaw/logs -name "*.log" -type f -mmin -60 2>/dev/null -exec tail -100 {} \; | grep -i "error\|fail\|critical" | head -5)

# 6. API Health (NVIDIA, Google)
nvidia_health=$(curl -s --max-time 5 "https://integrate.api.nvidia.com/v1/models" 2>&1 | grep -o '"object"' | wc -l)
google_health=$(curl -s --max-time 5 "https://generativelanguage.googleapis.com/v1beta/models" 2>&1 | grep -c "gemini-3-flash-preview")

# 7. Gateway Status
gateway_running=$(pgrep -a openclaw | grep -v grep | wc -l)

# 8. Disk Space Crítico
disk_critical=$(df -h / | awk 'NR==2{print $5}' | cut -d'%' -f1)
is_disk_low=0
if [ "$disk_critical" -gt 80 ]; then
    is_disk_low=1
fi

# Criar JSON completo
cat > "$CACHE_FILE" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "system": {
    "cpu_usage_pct": "$cpu_info",
    "memory_usage": "$mem_info",
    "disk_usage": "$disk_info"
  },
  "directories": {
    "workspace_disk": "$workspace_disk",
    "logs_disk": "$logs_disk"
  },
  "sessions": {
    "total": $session_count,
    "inactive_over_24h": $inactive_sessions
  },
  "logs": {
    "error_files_last_hour": $log_errors,
    "recent_errors_sample": "$recent_errors"
  },
  "apis": {
    "nvidia_healthy": [ "$nvidia_health" -gt 0 ],
    "google_healthy": [ "$google_health" -gt 0 ]
  },
  "gateway": {
    "running_processes": $gateway_running
  },
  "alert_flags": {
    "disk_low": $is_disk_low,
    "too_many_inactive": [ "$inactive_sessions" -gt 10 ]
  }
}
EOF

echo "✅ Health data collected: $CACHE_FILE"

# Exibe resumo para debug
cat "$CACHE_FILE" | jq .

# Retorna o arquivo para ser usado pelo LLM
echo "$CACHE_FILE"
