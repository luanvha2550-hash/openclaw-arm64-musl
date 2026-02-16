#!/bin/bash
# diagnose-openclaw-installation.sh
# Diagnóstico completo do problema de instalação OpenClaw
# Data: 2026-02-15

echo "🔍 DIAGNÓSTICO COMPLETO - OpenClaw Installation"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "═══════════════════════════════════════════════════════════"
echo "1. VERIFICAÇÃO SHELL E AMBIENTE"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "Shell disponíveis:"
which sh bash ash 2>/dev/null || echo "❌ Nenhum shell encontrado!"

echo ""
echo "Symlink sh → busybox:"
ls -la /bin/sh /usr/bin/sh 2>/dev/null || echo "❌ Symlink sh não encontrado"

echo ""
echo "PATH:"
echo "$PATH"

echo ""
echo "BusyBox test:"
if /bin/sh -c "echo 'BusyBox sh funciona'" 2>/dev/null; then
    echo -e "${GREEN}✅ BusyBox sh funciona${NC}"
else
    echo -e "${RED}❌ BusyBox sh com erro${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "2. VERIFICAÇÃO NODE/NPM"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "Node version:"
which node && node --version || echo "❌ Node não encontrado"

echo ""
echo "NPM version:"
which npm && npm --version || echo "❌ NPM não encontrado"

echo ""
echo "NPM global packages instalados:"
npm list -g --depth 0 2>&1 | head -10 || echo "❌ Erro ao listar"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "3. VERIFICAÇÃO OPENCLAW INSTALAÇÃO"
echo "═══════════════════════════════════════════════════════════"

OPENCLAW_DIR="/usr/local/lib/node_modules/openclaw"

if [ -d "$OPENCLAW_DIR" ]; then
    echo -e "${GREEN}✅ Diretório openclaw existe${NC}"
    echo "   Caminho: $OPENCLAW_DIR"
    echo "   Conteúdo:"
    ls -lh "$OPENCLAW_DIR"
else
    echo -e "${RED}❌ Diretório openclaw NÃO existe${NC}"
fi

echo ""
echo "package.json:"
if [ -f "$OPENCLAW_DIR/package.json" ]; then
    echo -e "${GREEN}✅ package.json existe${NC}"
    cat "$OPENCLAW_DIR/package.json" | jq -r '.name, .version' 2>/dev/null || echo "   (JSON inválido)"
else
    echo -e "${RED}❌ package.json NÃO existe${NC}"
fi

echo ""
echo "bin/ diretorio:"
if [ -d "$OPENCLAW_DIR/bin" ]; then
    echo -e "${GREEN}✅ bin/ existe${NC}"
    ls -lh "$OPENCLAW_DIR/bin/"
else
    echo -e "${RED}❌ bin/ NÃO existe${NC}"
fi

echo ""
echo "node_modules/ size:"
if [ -d "$OPENCLAW_DIR/node_modules" ]; then
    echo -e "${GREEN}✅ node_modules/ existe${NC}"
    size=$(du -sh "$OPENCLAW_DIR/node_modules" | cut -f1)
    count=$(find "$OPENCLAW_DIR/node_modules" -name "package.json" | wc -l)
    echo "   Tamanho: $size"
    echo "   Pacotes: $count"
else
    echo -e "${RED}❌ node_modules/ NÃO existe${NC}"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "4. VERIFICAÇÃO ERRO ANTERIOR"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "Log da última instalação:"
if [ -f "/home/moltuser/.npm/_logs/$(ls -t /home/moltuser/.npm/_logs/ | head -1)" ]; then
    cat "/home/moltuser/.npm/_logs/$(ls -t /home/moltuser/.npm/_logs/ | head -1)" | tail -50
else
    echo "❌ Nenhum log encontrado"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "5. RECOMENDAÇÕES"
echo "═══════════════════════════════════════════════════════════"

echo ""

# Diagnóstico
if [ ! -f "$OPENCLAW_DIR/package.json" ]; then
    echo -e "${RED}⚠️  DIAGNÓSTICO: Instalação incompleta${NC}"
    echo ""
    echo "Soluções possíveis:"
    echo "1. Remover instalação corrompida:"
    echo "   sudo rm -rf $OPENCLAW_DIR"
    echo ""
    echo "2. Tentar reinstall com flags:"
    echo "   npm i -g --force --no-scripts openclaw@2026.2.2"
    echo ""
    echo "3. Tentar do fork do Luan:"
    echo "   npm i -g --force --no-scripts luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl"
    echo ""
    echo "4. Chamar agente Llama para debugging avançado"
fi

echo ""
echo -e "${YELLOW}💡 NOTA: Problema pode ser scripts de postinstall tentando usar sh${NC}"
echo -e "${YELLOW}   mas PostmarketOS usa BusyBox sh que tem limitações${NC}"
