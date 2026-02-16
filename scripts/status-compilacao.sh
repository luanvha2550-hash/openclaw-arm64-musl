#!/bin/bash
# status-compilacao.sh - Monitora status da compilação node-llama-cpp
# Data: 2026-02-15

echo "🔍 Monitorando compilação node-llama-cpp..."
echo "======================================"
echo ""

# Verificar se processo npm está rodando
if ps aux | grep -v grep | grep -q "npm"; then
    echo "✅ Compilação RODANDO"
    echo ""
    echo "Processos ativos:"
    ps aux | grep npm | grep -v grep
else
    echo "❌ Compilação NÃO está rodando"
    exit 0
fi

echo ""
echo "📊 Recursos:"
echo ""
echo "RAM:"
free -h
echo ""
echo "CPU:"
top -bn1 | grep "Cpu(s)"
echo ""
echo "Disco:"
df -h / | grep "/$"

echo ""
echo "📁 Progresso:"
if [ -d "/tmp/node-llama-binaries" ]; then
    echo "Binários copiados: $(find /tmp/node-llama-binaries -name "*.node" -o -name "*.so" | wc -l)"
else
    echo "Nenhum binário copiado ainda"
fi

echo ""
echo "🔍 Logs:"
# Últimas 10 linhas de monitoramento
if [ -f "/tmp/monitor-$$.log" ]; then
    tail -10 "/tmp/monitor-$$.log"
else
    echo "Nenhum log de monitoramento encontrado"
fi

echo ""
echo "⏱️  Tempo desde início:"
if [ -f "/tmp/monitor-$$.log" ]; then
    first_line=$(head -1 "/tmp/monitor-$$.log" | cut -d' ' -f1-2)
    echo "Iniciado: $first_line"
else
    echo "Nenhum monitoramento iniciado"
fi
