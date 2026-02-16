#!/bin/bash
# fix-openclaw-install.sh
# Tenta reparar instalação do OpenClaw
# Data: 2026-02-15

set -e

echo "🔧 TENTANDO REPARAR OPENCLAW"
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Remover instalação corrompida
echo "1️⃣ Removendo instalação incompleta..."
npm uninstall -g openclaw 2>/dev/null || echo "  (já não existia)"
if [ -L "/usr/local/lib/node_modules/openclaw" ]; then
    sudo rm -f "/usr/local/lib/node_modules/openclaw"
fi
echo -e "${GREEN}✅ Removido${NC}"
echo ""

# 2. Escolher método de instalação
echo "Escolha método de instalação:"
echo ""
echo "1. Instalação SEM scripts de postinstall (mais rápido, pode não ter node-llama-cpp compilado)"
echo "2. Instalação do npm oficial (estável, mas vai tentar compilar node-llama-cpp)"
echo "3. Abortar"
echo ""
read -p "Opção [1-3]: " choice

case $choice in
    1)
        echo ""
        echo "2️⃣ Instalando do fork do Luan (SEM scripts)..."
        npm i -g --force --no-scripts luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl
        ;;
    2)
        echo ""
        echo "2️⃣ Instalando do npm oficial..."
        npm i -g openclaw@2026.2.2
        ;;
    3)
        echo "Abortado."
        exit 0
        ;;
    *)
        echo -e "${RED}Opção inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo "3️⃣ Verificando instalação..."

# Verificar se binário existe
if [ -f "/usr/local/lib/node_modules/openclaw/bin/openclaw" ]; then
    echo -e "${GREEN}✅ Binário encontrad0${NC}"

    # Criar symlink em /usr/local/bin
    sudo ln -sf /usr/local/lib/node_modules/openclaw/bin/openclaw /usr/local/bin/openclaw
    echo -e "${GREEN}✅ Symlink criado${NC}"

    # Testar
    if command -v openclaw &> /dev/null; then
        echo ""
        VERSION=$(openclaw --version 2>/dev/null || echo "??")
        echo -e "${GREEN}✅ OpenClaw funcionando!${NC}"
        echo "   Versão: $VERSION"
        echo ""
        echo "🎉 SUCESSO!"
    else
        echo -e "${RED}❌ openclaw comando não funciona${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Binário NÃO encontrado!${NC}"
    echo ""
    echo "Caminho esperado:"
    echo "  /usr/local/lib/node_modules/openclaw/bin/openclaw"
    echo ""
    echo "Conteúdo real:"
    ls -la /usr/local/lib/node_modules/openclaw/ 2>/dev/null || echo "  (diretório não existe)"
    exit 1
fi
