#!/bin/bash
# backup-node-llama-binaries.sh
# Faz backup dos binários node-llama-cpp compilados para ARM64
# Data: 2026-02-15

set -e

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Diretórios
NODE_LLAMA="/usr/local/lib/node_modules/openclaw/node-llama-cpp"
BACKUP_DIR="/tmp/node-llama-cpp-backup"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ARCHIVE="/tmp/node-llama-cpp-arm64-backup-$TIMESTAMP.tar.gz"

echo "🔧 Backup binários node-llama-cpp (ARM64)"
echo "Data: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# Criar diretório temporário
mkdir -p "$BACKUP_DIR"

echo "📂 Fonte: $NODE_LLAMA"
echo "📦 Backup: $BACKUP_DIR"
echo "📁 Arquivo: $ARCHIVE"
echo ""

# Verificar se binários existem
LLAMA_NODE="$NODE_LLAMA/dist/bindings/bindings/arm64/linux-arm64/Llama.node"
LIB_DIR="$NODE_LLAMA/llama/localBuilds/linux-arm64"

if [ ! -f "$LLAMA_NODE" ]; then
    echo -e "${RED}❌ ERRO: Llama.node não encontrado!${NC}"
    echo "Caminho: $LLAMA_NODE"
    echo ""
    echo "Parece que a compilação não completou ou o binário está em outro local."
    exit 1
fi

if [ ! -d "$LIB_DIR" ]; then
    echo -e "${YELLOW}⚠️  Aviso: Diretório libs não encontrado${NC}"
    echo "Caminho: $LIB_DIR"
    echo ""
    echo "Continuando sem libs (apenas Llama.node)..."
    BACKUP_ONLY_BINDING=true
else
    BACKUP_ONLY_BINDING=false
fi

# Copiar binários
echo "📥 Copiando binários..."

cp "$LLAMA_NODE" "$BACKUP_DIR/"
echo -e "  ${GREEN}✅${NC} Llama.node"

if [ "$BACKUP_ONLY_BINDING" = false ]; then
    for lib in "$LIB_DIR"/lib*.so; do
        if [ -f "$lib" ]; then
            cp "$lib" "$BACKUP_DIR/"
            echo -e "  ${GREEN}✅${NC} $(basename $lib)"
        fi
    done
fi

# Criar archive comprimido
echo ""
echo "📦 Criando archive comprimido..."
tar czf "$ARCHIVE" -C /tmp node-llama-cpp-backup/

ARCHIVE_SIZE=$(du -h "$ARCHIVE" | cut -f1)
echo -e "${GREEN}✅ Archive criado: $ARCHIVE${NC}"
echo "   Tamanho: $ARCHIVE_SIZE"
echo ""

# Listar conteúdo
echo "📋 Conteúdo do backup:"
tar tzf "$ARCHIVE"
echo ""

# Instruções
echo -e "${YELLOW}📥 Para transferir para seu PC:${NC}"
echo ""
echo "Método 1: Telegram (via openclaw message)"
echo "  Comando para enviar o arquivo:"
echo "  message://target=SEU_TELEGRAM_ID?path=$ARCHIVE"
echo ""
echo "Método 2: SCP (se tiver SSH)"
echo "  scp $ARCHIVE seu-pc@ip:/destino/"
echo ""
echo "Método 3: USB/Transferência direta"
echo "  Copiar: cp $ARCHIVE /sdcard/Download/"
echo ""
echo -e "${GREEN}✅ Backup concluído com sucesso!${NC}"
