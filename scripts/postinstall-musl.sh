#!/bin/bash
# postinstall-musl.sh
# Script para instalar binários compatíveis com ARM64 musl após npm install
# Repo: https://github.com/luanvha2550-hash/openclaw-arm64-musl

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🦞 OpenClaw ARM64 musl postinstall${NC}"

# Detectar arquitetura
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ] && [ "$ARCH" != "arm64" ]; then
    echo -e "${GREEN}✅ Arquitetura $ARCH não precisa de patches musl${NC}"
    exit 0
fi

# Detectar se é musl
if ldd --version 2>&1 | grep -qi "musl"; then
    IS_MUSL=true
else
    IS_MUSL=false
fi

if [ "$IS_MUSL" = false ]; then
    echo -e "${GREEN}✅ Sistema glibc detectado, não precisa de patches musl${NC}"
    exit 0
fi

echo -e "${YELLOW}🔧 Sistema ARM64 musl detectado, instalando binários compatíveis...${NC}"

# Determinar diretório de instalação
if [ -d "/usr/local/lib/node_modules/openclaw" ]; then
    OPENCLAW_DIR="/usr/local/lib/node_modules/openclaw"
elif [ -d "$HOME/.npm-global/lib/node_modules/openclaw" ]; then
    OPENCLAW_DIR="$HOME/.npm-global/lib/node_modules/openclaw"
elif [ -d "$HOME/.bun/install/global/node_modules/openclaw" ]; then
    OPENCLAW_DIR="$HOME/.bun/install/global/node_modules/openclaw"
else
    # Tentar encontrar via npm root -g
    NPM_ROOT=$(npm root -g 2>/dev/null)
    if [ -n "$NPM_ROOT" ] && [ -d "$NPM_ROOT/openclaw" ]; then
        OPENCLAW_DIR="$NPM_ROOT/openclaw"
    else
        echo -e "${RED}❌ Não foi possível encontrar o diretório do OpenClaw${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}📁 Diretório do OpenClaw: $OPENCLAW_DIR${NC}"

# URL base para download dos binários (GitHub Releases do fork)
BASE_URL="https://github.com/luanvha2550-hash/openclaw-arm64-musl/releases/latest/download"
VERSION="latest"

# Criar diretório temporário
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

# ============================================
# INSTALAR SQLITE-VEC
# ============================================
echo ""
echo -e "${BLUE}📦 Instalando sqlite-vec para ARM64 musl...${NC}"

SQLITE_VEC_DIR="$OPENCLAW_DIR/node_modules/sqlite-vec-linux-arm64"
mkdir -p "$SQLITE_VEC_DIR"

# Baixar vec0.so
if curl -fsSL "$BASE_URL/vec0.so" -o "$TMP_DIR/vec0.so" 2>/dev/null; then
    cp "$TMP_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so"
    # Criar symlink para vec0.so.so (necessário para o node-llama-cpp)
    ln -sf "$SQLITE_VEC_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so.so"
    echo -e "${GREEN}✅ sqlite-vec instalado com sucesso!${NC}"
else
    echo -e "${YELLOW}⚠️  Não foi possível baixar vec0.so do GitHub${NC}"
    echo -e "${YELLOW}   Tentando usar binário local...${NC}"
    
    # Tentar usar binário local se existir
    LOCAL_VEC="/mnt/sdcard/compilados/vec0.so"
    if [ -f "$LOCAL_VEC" ]; then
        cp "$LOCAL_VEC" "$SQLITE_VEC_DIR/vec0.so"
        ln -sf "$SQLITE_VEC_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so.so"
        echo -e "${GREEN}✅ sqlite-vec instalado do diretório local!${NC}"
    else
        echo -e "${RED}❌ vec0.so não encontrado${NC}"
    fi
fi

# ============================================
# RESUMO
# ============================================
echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Postinstall ARM64 musl concluído!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo -e "📁 Binários instalados em:"
echo -e "   sqlite-vec: $SQLITE_VEC_DIR/vec0.so"
echo ""
echo -e "${YELLOW}⚠️  Nota: llama.cpp local não está disponível para musl.${NC}"
echo -e "${YELLOW}   Use modelos via API (Google, NVIDIA, etc) ou Ollama externo.${NC}"
echo ""

exit 0
