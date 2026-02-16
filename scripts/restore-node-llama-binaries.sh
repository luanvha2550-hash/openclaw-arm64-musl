#!/bin/bash
# restore-node-llama-binaries.sh
# Restaura binários node-llama-cpp do backup
# Data: 2026-02-15

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Diretórios
NODE_LLAMA="/usr/local/lib/node_modules/openclaw/node-llama-cpp"
BINDING_DIR="$NODE_LLAMA/dist/bindings/bindings/arm64/linux-arm64"
LIB_DIR="$NODE_LLAMA/llama/localBuilds/linux-arm64"

echo "🔧 Restauração binários node-llama-cpp (ARM64)"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Verificar argumento
if [ -z "$1" ]; then
    echo "Uso: $0 /caminho/do/backup-node-llama-cpp-arm64-YYYYMMDD-HHMMSS.tar.gz"
    echo ""
    echo "Exemplo:"
    echo "  $0 /tmp/node-llama-cpp-arm64-backup-20260215-180000.tar.gz"
    exit 1
fi

ARCHIVE="$1"

# Verificar se archive existe
if [ ! -f "$ARCHIVE" ]; then
    echo -e "${RED}❌ Erro: Archive não encontrado${NC}"
    echo "Caminho: $ARCHIVE"
    exit 1
fi

# Listar conteúdo do archive
echo "📋 Conteúdo do backup:"
tar tzf "$ARCHIVE"
echo ""

# Confirmar
read -p "Deseja restaurar estes binários? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Criar diretórios se não existirem
echo ""
echo "📂 Preparando diretórios..."
mkdir -p "$BINDING_DIR"
mkdir -p "$LIB_DIR"

# Extrair para temporário
echo "📦 Extrair backup..."
EXTRACT_DIR="/tmp/node-llama-cpp-restore-$(date +%s)"
mkdir -p "$EXTRACT_DIR"
tar xzf "$ARCHIVE" -C "$EXTRACT_DIR"

# Copiar binários
echo ""
echo "📥 Restaurando binários..."

# Llama.node
if [ -f "$EXTRACT_DIR/node-llama-cpp-backup/Llama.node" ]; then
    cp "$EXTRACT_DIR/node-llama-cpp-backup/Llama.node" "$BINDING_DIR/"
    chmod +x "$BINDING_DIR/Llama.node"
    echo -e "  ${GREEN}✅${NC} Llama.node → $BINDING_DIR/"
fi

# Libs
for lib in "$EXTRACT_DIR/node-llama-cpp-backup/lib"*.so; do
    if [ -f "$lib" ]; then
        cp "$lib" "$LIB_DIR/"
        chmod +x "$LIB_DIR/$(basename $lib)"
        echo -e "  ${GREEN}✅${NC} $(basename $lib) → $LIB_DIR/"
    fi
done

# Limpar temporário
rm -rf "$EXTRACT_DIR"

echo ""
echo -e "${GREEN}✅ Restauração concluída!${NC}"
echo ""
echo "🧪 Testar instalação:"
echo "  openclaw doctor --non-interactive"
echo ""
echo "📋 Verificar binários:"
echo "  file $BINDING_DIR/Llama.node"
echo "  ls -lh $LIB_DIR/"
