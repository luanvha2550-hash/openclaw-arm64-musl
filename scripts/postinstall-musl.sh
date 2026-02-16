#!/bin/bash
# postinstall-musl.sh
# Script para instalar binários compatíveis com ARM64 musl após npm install
# Repo: https://github.com/luanvha2550-hash/openclaw-arm64-musl
# Autor: Luan Henrique + Atlas (OpenClaw)
# Data: 2026-02-15

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

# Determinar diretório de instalação do OpenClaw
OPENCLAW_DIR=""

# Método 1: Usar variável de ambiente se definida
if [ -n "$npm_config_prefix" ]; then
    CANDIDATE="$npm_config_prefix/lib/node_modules/openclaw"
    if [ -d "$CANDIDATE" ]; then
        OPENCLAW_DIR="$CANDIDATE"
    fi
fi

# Método 2: Diretórios comuns
if [ -z "$OPENCLAW_DIR" ]; then
    for dir in \
        "/usr/local/lib/node_modules/openclaw" \
        "$HOME/.npm-global/lib/node_modules/openclaw" \
        "$HOME/.bun/install/global/node_modules/openclaw" \
        "$HOME/.local/lib/node_modules/openclaw"
    do
        if [ -d "$dir" ]; then
            OPENCLAW_DIR="$dir"
            break
        fi
    done
fi

# Método 3: Usar npm root -g
if [ -z "$OPENCLAW_DIR" ]; then
    NPM_ROOT=$(npm root -g 2>/dev/null || true)
    if [ -n "$NPM_ROOT" ] && [ -d "$NPM_ROOT/openclaw" ]; then
        OPENCLAW_DIR="$NPM_ROOT/openclaw"
    fi
fi

if [ -z "$OPENCLAW_DIR" ]; then
    echo -e "${RED}❌ Não foi possível encontrar o diretório do OpenClaw${NC}"
    echo -e "${YELLOW}   Isso pode acontecer durante build local. Ignorando...${NC}"
    exit 0
fi

echo -e "${BLUE}📁 Diretório do OpenClaw: $OPENCLAW_DIR${NC}"

# URL base para download dos binários (GitHub Releases do fork)
BASE_URL="https://github.com/luanvha2550-hash/openclaw-arm64-musl/releases/latest/download"

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

# Tentar baixar vec0.so do GitHub Releases
if curl -fsSL "$BASE_URL/vec0.so" -o "$TMP_DIR/vec0.so" 2>/dev/null; then
    cp "$TMP_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so"
    chmod 644 "$SQLITE_VEC_DIR/vec0.so"
    # Criar symlink para vec0.so.so (necessário para alguns módulos)
    ln -sf "$SQLITE_VEC_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so.so"
    echo -e "${GREEN}✅ sqlite-vec instalado do GitHub Releases!${NC}"
else
    echo -e "${YELLOW}⚠️  Não foi possível baixar vec0.so do GitHub${NC}"
    echo -e "${YELLOW}   Tentando usar binário local...${NC}"
    
    # Tentar usar binário local se existir
    for local_path in \
        "/mnt/sdcard/compilados/vec0.so" \
        "$HOME/compilados/vec0.so" \
        "/tmp/vec0.so"
    do
        if [ -f "$local_path" ]; then
            cp "$local_path" "$SQLITE_VEC_DIR/vec0.so"
            ln -sf "$SQLITE_VEC_DIR/vec0.so" "$SQLITE_VEC_DIR/vec0.so.so"
            echo -e "${GREEN}✅ sqlite-vec instalado de: $local_path${NC}"
            break
        fi
    done
    
    if [ ! -f "$SQLITE_VEC_DIR/vec0.so" ]; then
        echo -e "${RED}❌ vec0.so não encontrado em lugar nenhum${NC}"
        echo -e "${YELLOW}   A busca vetorial na memória pode não funcionar.${NC}"
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
