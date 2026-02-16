#!/bin/bash
# COMPILAR node-llama-cpp NATIVO NO ZENFONE (OTIMIZADO)
# Data: 2026-02-15 - Versão otimizada baseada em revisão Llama-inspired

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==========================================
# CONFIGURAÇÕES
# ==========================================
TIMEOUT_COMPILACAO=1800  # 30 min
RAM_MINIMA_MB=500
DISCO_MINIMO_MB=2048
RETRY_TENTATIVAS=2

BACKUP_DIR="/tmp/node-llama-binaries"
NODE_LLAMA_DIR="/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp"

# ==========================================
# FUNÇÕES AUXILIARES
# ==========================================

verificar_recursos() {
    local ram=$(free | awk '/Mem:/{printf "%.0f", $7/1024}')
    local disk=$(df -m / | awk 'NR==2{print $4}')

    echo "RAM disponível: ${ram} MB (mín: ${RAM_MINIMA_MB} MB)"
    echo "Disco disponível: ${disk} MB (mín: ${DISCO_MINIMO_MB} MB)"

    if [ "$ram" -lt "$RAM_MINIMA_MB" ]; then
        echo -e "${RED}RAM insuficiente!${NC}"
        return 1
    fi

    if [ "$disk" -lt "$DISCO_MINIMO_MB" ]; then
        echo -e "${RED}Disco insuficiente!${NC}"
        return 1
    fi

    return 0
}

executar_com_timeout() {
    local cmd="$1"
    local timeout="$2"
    local desc="$3"

    echo -e "${CYAN}Executando: $desc${NC}"
    echo -e "${YELLOW}Timeout: $timeout segundos${NC}"

    timeout "$timeout" bash -c "$cmd" || return $?
}

extract_binarios() {
    echo -e "${CYAN}Extraindo binários...${NC}"
    mkdir -p "$BACKUP_DIR"

    local binarios=0
    local libs=0

    # Llama.node
    if [ -f "$NODE_LLAMA_DIR/dist/bindings/bindings/arm64/linux-arm64/Llama.node" ]; then
        cp "$NODE_LLAMA_DIR/dist/bindings/bindings/arm64/linux-arm64/Llama.node" "$BACKUP_DIR/"
        echo -e "${GREEN}✅ Llama.node copiado${NC}"
        ((binarios++))
    elif [ -f "/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl/Llama.node" ]; then
        cp "/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl/Llama.node" "$BACKUP_DIR/"
        echo -e "${GREEN}✅ Llama.node copiado (alpine-musl)${NC}"
        ((binarios++))
    fi

    # Libs
    if [ -d "$NODE_LLAMA_DIR/llama/localBuilds/linux-arm64" ]; then
        for lib in "$NODE_LLAMA_DIR/llama/localBuilds/linux-arm64"/lib*.so; do
            if [ -f "$lib" ]; then
                cp "$lib" "$BACKUP_DIR/"
                ((libs++))
            fi
        done
        echo -e "${GREEN}✅ $libs libs copiadas${NC}"
    fi

    # Backup info
    cat > "$BACKUP_DIR/info.txt" <<EOF
Backup node-llama-cpp ARM64
Data: $(date '+%Y-%m-%d %H:%M:%S')
Binários: $binarios
Libs: $libs
EOF

    return 0
}

# ==========================================
# EXECUÇÃO PRINCIPAL
# ==========================================

echo "🔧 Compilando node-llama-cpp NATIVO ARM64"
echo "======================================"
echo ""

# FASE 1: PREPARAÇÃO
echo -e "${CYAN}FASE 1: PREPARAÇÃO${NC}"
echo ""

echo "[1/4] NPM shell fix..."
npm config set script-shell /bin/sh

echo "[2/4] Verificando recursos..."
if ! verificar_recursos; then
    echo -e "${YELLOW}Recursos abaixo do recomendado${NC}"
    read -p "Continuar mesmo assim? (s/N): " confirm
    if [[ ! "$confirm" =~ ^[sS]$ ]]; then
        echo "Cancelado."
        exit 1
    fi
fi

echo "[3/4] Limpando anterior..."
npm uninstall -g openclaw 2>/dev/null || true
sudo rm -rf "$USERPROFILE/.npm-global" 2>/dev/null || true

echo "[4/4] Diretórios..."
mkdir -p "$BACKUP_DIR"

echo ""
echo -e "${GREEN}✅ FASE 1 completa${NC}"

# FASE 2: COMPILAÇÃO
echo ""
echo -e "${CYAN}FASE 2: COMPILAÇÃO${NC}"
echo ""
echo "⏱️  Tempo: 15-30 min | CPU: alta | RAM: alta"
read -p "Confirmar e iniciar? (s/N): " confirm
if [[ ! "$confirm" =~ ^[sS]$ ]]; then
    echo "Cancelado."
    exit 1
fi

echo ""
echo "Instalando OpenClaw..."

sucesso=0
for tentativa in $(seq 1 $RETRY_TENTATIVAS); do
    echo ""
    echo -e "${CYAN}Tentativa $tentativa/$RETRY_TENTATIVAS${NC}"

    if ejecutar_com_timeout "npm i -g openclaw@2026.2.2" $TIMEOUT_COMPILACAO "Instalação OpenClaw"; then
        sucesso=1
        break
    else
        local exit=$?
        if [ $exit -eq 124 ]; then
            echo -e "${RED}TIMEOUT (mais de 30 min)${NC}"
        fi

        if [ $tentativa -lt $RETRY_TENTATIVAS ]; then
            echo -e "${YELLOW}Tentando novamente em 5 seg...${NC}"
            sleep 5
        fi
    fi
done

if [ $sucesso -eq 0 ]; then
    echo -e "${RED}Falha após $RETRY_TENTATIVAS tentativas${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Instalação completa${NC}"

# FASE 3: EXTRAIÇÃO
echo ""
echo -e "${CYAN}FASE 3: EXTRAIÇÃO DE BINÁRIOS${NC}"
echo ""

if [ ! -d "$NODE_LLAMA_DIR" ]; then
    echo -e "${RED}node-llama-cpp não encontrado${NC}"
    exit 1
fi

extract_binarios

echo ""
echo -e "${GREEN}✅ Binários extraídos para $BACKUP_DIR${NC}"

# FASE 4: EMPACOTAR
echo ""
echo -e "${CYAN}FASE 4: EMPACOTAR${NC}"
echo ""

cd /tmp
tar czf node-llama-binaries.tar.gz node-llama-binaries/

SIZE=$(du -h node-llama-binaries.tar.gz | cut -f1)
echo -e "${GREEN}✅ Criado: /tmp/node-llama-binaries.tar.gz ($SIZE)${NC}"

# RESUMO FINAL
echo ""
echo "======================================"
echo -e "${GREEN}✅ COMPILAÇÃO CONCLUÍDA${NC}"
echo "======================================"
echo ""
echo "📦 Arquivos:"
ls -lh "$BACKUP_DIR/"
echo ""
echo "Backup: /tmp/node-llama-binaries.tar.gz ($SIZE)"
echo ""
echo "PRÓXIMO PASSO:"
echo "  Transferir para fork do Luan: prebuilt/linux-arm64-musl/"
