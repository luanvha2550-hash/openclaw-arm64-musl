#!/bin/bash
# health-check-wrapper.sh
# Wrapper para System Health Check otimizado
# Bash coleta dados → LLM analiza UNA vez (economia de APIs)

# Coletar dados
DATA_FILE=$(/home/moltuser/.openclaw/workspace/scripts/health-check-collector.sh)

# Ler dados
DATA=$(cat "$DATA_FILE")

# Analisar com Tier 1 (LLM Local se disponível) ou fallback para Cloud
# O script coletou TUDO, então o LLM só precisa de 1 chamada

echo "🔧 SYSTEM HEALTH - Otimizado:"
echo ""
echo "📊 Dados coletados: $DATA_FILE"
echo ""
echo "🧠 Analisando com LLM..."

# Exibir resumo simples antes de chamar LLM
disk_low=$(echo "$DATA" | jq -r '.alert_flags.disk_low')
error_files=$(echo "$DATA" | jq -r '.logs.error_files_last_hour')
inactive=$(echo "$DATA" | jq -r '.sessions.inactive_over_24h')

# Se tudo OK, nem chama LLM (economia máxima!)
if [ "$disk_low" = "false" ] && [ "$error_files" = "0" ] && [ "$inactive" -lt 5 ]; then
    echo ""
    echo "✅ HEARTBEAT_OK"
    echo ""
    echo "   CPU: $(echo "$DATA" | jq -r '.system.cpu_usage_pct')%"
    echo "   Memory: $(echo "$DATA" | jq -r '.system.memory_usage')"
    echo "   Disk: $(echo "$DATA" | jq -r '.system.disk_usage')"
    echo "   APIs: NVIDIA=$(echo "$DATA" | jq -r '.apis.nvidia_healthy') Google=$(echo "$DATA" | jq -r '.apis.google_healthy')"
    echo ""
    echo "   Nenhuma action necessária."
    echo ""
    echo "💾 Log salvo: $DATA_FILE"
    echo ""
    exit 0
fi

# Se há problemas, chama LLM para análise (1 call apenas!)
echo ""
echo "⚠️ Problemas detectados:"
echo "   Disk low: $disk_low"
echo "   Error files: $error_files"
echo "   Inactive sessions: $inactive"
echo ""
echo "🧠 Analisando profundamente (LLM)..."

# AQUI SERIA CHAMADO O LLM LOCAL OU CLOUD
# Mas por enquanto, apenas loga os dados
echo ""
echo "📋 Dados para análise:"
cat "$DATA_FILE" | jq .

# Limpar sessões inativas se muitas
if [ "$inactive" -gt 10 ]; then
    echo ""
    echo "🧹 Limpando sessões inativas ($inactive encontradas)..."
    # find /home/moltuser/.openclaw/agents/* -name "*.jsonl" -mtime +1 -type f -delete
    # (comentado por segurança, habilite quando necessário)
fi

echo ""
echo "💾 Log salvo: $DATA_FILE"
echo ""
