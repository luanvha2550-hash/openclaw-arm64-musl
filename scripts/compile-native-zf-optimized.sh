#!/bin/bash
# compile-native-zf-shim.sh - Script PRINCIPAL para compilação node-llama-cpp no ZenFone
# Melhorado com timeout, retry logic, monitoramento de recursos
# Data: 2026-02-15 - Revisado por Llamo-inspired optimizations

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configurações
TIMEOUT_COMPILACAO=1800  # 30 min timeout para compilação
VERIFICACAO_RAM_MIN_MB=500  # RAM mínima necessária
VERIFICACAO_DISCO_MIN_MB=2048  # Disk mínimo necessário
RETRY_INSTALL=2  # Retry se falhar

# Diretórios
BACKUP_DIR="/tmp/node-llama-binaries"
NODE_LLAMA_DIR="/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp"

echo "🔧 Compilando node-llama-cpp NATIVO ARM64 - ZenFone"
echo "================================================"
echo ""

# Função para verificar recursos
verificar_recursos() {
    local ram_avail_mb=$(free | awk '/Mem:/{printf "%.0f", $7/1024}')
    local disk_avail_mb=$(df -m / | awk 'NR==2{print $4}')

    echo -e "${CYAN}Recursos disponíveis:${NC}"
    echo "RAM livre: ${ram_avail_mb} MB (mínimo: ${VERIFICACAO_RAM_MIN_MB} MB)"
    echo "Disco livre: ${disk_avail_mb} MB (mínimo: ${VERIFICACAO_DISCO_MIN_MB} MB)"

    if [ "$ram_avail_mb" -lt "$VERIFICACAO_RAM_MIN_MB" ]; then
        echo -e "${RED}❌ RAM insuficiente!${NC}"
        echo "Feche outros apps ou use swap"
        return 1
    fi

    if [ "$disk_avail_mb" -lt "$VERIFICACAO_DISCO_MIN_MB" ]; then
        echo -e "${RED}❌ Disco insuficiente!${NC}"
        echo "Libere espaço no armazenamento"
        return 1
    fi

    echo -e "${GREEN}✅ Recursos OK${NC}"
    return 0
}

# Função para monitorar CPU/RAM durante compilação
monitorar_recursos() {
    local pid=$1
    local logfile="/tmp/monitor-${pid}.log"

    while kill -0 "$pid" 2>/dev/null; do
        local ram_total=$(free | awk '/Mem:/{print $2/1024}')
        local ram_used=$(free | awk '/Mem:/{print $3/1024}')
        local ram_perc=$((ram_used * 100 / ram_total))
        local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)

        echo "$(date '+%H:%M:%S') - RAM: ${ram_perc}% | CPU: ${cpu_usage}%" >> "$logfile"

        # Alerta se RAM > 95%
        if [ "$ram_perc" -gt 95 ]; then
            echo -e "${YELLOW}⚠️  RAM CRÍTICA! ${ram_perc}%${NC}"
        fi

        sleep 10
    done
}

# Função para executar com timeout
executar_com_timeout() {
    local cmd="$1"
    local timeout=$2
    local desc="$3"

    echo ""
    echo -e "${CYAN}Executando: $desc${NC}"
    echo -e "${YELLOW}Timeout: $timeout segundos${NC}"

    timeout $timeout bash -c "$cmd" || {
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}❌ TIMEOUT! Operação demorou muito${NC}"
            return 124
        else
            echo -e "${RED}❌ ERRO (exit $exit_code)${NC}"
            return $exit_code
        fi
    }

    return 0
}

# ==========================================
# FASE 1: PREPARAÇÃO
# ==========================================
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}FASE 1: PREPARAÇÃO${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "[1/5] Corrigindo configuração npm shell..."
npm config set script-shell /bin/sh
echo -e "${GREEN}✅ Shell configurado${NC}"

echo ""
echo "[2/5] Verificando recursos disponíveis..."
verificar_recursos || {
    read -p "Deseja continuar mesmo assim? (S/N): " forcar
    if [[ ! $forcar =~ ^[Ss]$ ]]; then
        echo "Cancelado."
        exit 1
    fi
}

echo ""
echo "[3/5] Limpando instalação anterior..."
npm uninstall -g openclaw 2>/dev/null && echo -e "${GREEN}  openclaw desinstalado${NC}" || echo -e "${YELLOW}  openclaw não instalado (OK)${NC}"
sudo rm -rf /usr/local/lib/node_modules/openclaw 2>/dev/null || true
echo -e "${GREEN}✅ Limpeza concluída${NC}"

echo ""
echo "[4/5] Preparando diretórios..."
mkdir -p "$BACKUP_DIR"
echo -e "${GREEN}✅ Diretório de backup: $BACKUP_DIR${NC}"

echo ""
echo "[5/5] Sincronizando cache npm..."
npm cache clean --force
echo -e "${GREEN}✅ Cache limpo${NC}"

# ==========================================
# FASE 2: INSTALAÇÃO/COMPILAÇÃO
# ==========================================
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}FASE 2: INSTALAÇÃO/COMPILAÇÃO${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "⏱️  Tempo estimado: 15-30 min"
echo "⚠️  Vai usar muita CPU e RAM"
echo "Pressione Ctrl+C para cancelar"
echo ""
read -p "Continuar? (S/N): " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

echo ""
echo "Instalando OpenClaw (isso vai compilar node-llama-cpp)..."

# Try install with retry
INSTALL_SUCCESS=0
for attempt in $(seq 1 $RETRY_INSTALL); do
    echo ""
    echo -e "${CYAN}Tentativa $attempt/$RETRY_INSTALL...${NC}"

    # Start resource monitor in background
    monitorar_recursos $$ &
    MONITOR_PID=$!

    # Install with timeout
    if ejecutar_com_timeout "npm i -g openclaw@2026.2.2" $TIMEOUT_COMPILACAO "Instalação OpenClaw"; then
        INSTALL_SUCCESS=1
        kill $MONITOR_PID 2>/dev/null || true
        break
    else
        INSTALL_EXIT_CODE=$?
        kill $MONITOR_PID 2>/dev/null || true

        if [ $INSTALL_EXIT_CODE -eq 124 ]; then
            echo -e "${RED}❌ Compilação TIMEOUT (mais de 30 min)${NC}"
            echo "Sugestão: Feche outros apps, libere RAM, ou use swap"
        fi

        if [ $attempt -lt $RETRY_INSTALL ]; then
            echo -e "${YELLOW}Tentando novamente em 5 segundos...${NC}"
            sleep 5
        fi
    fi
done

if [ "$INSTALL_SUCCESS" -eq 0 ]; then
    echo ""
    echo -e "${RED}❌ FALHA NA INSTALAÇÃO APÓS $RETRY_INSTALL TENTATIVAS${NC}"
    echo ""
    echo "Log de monitoramento:"
    if [ -f "/tmp/monitor-$$.log" ]; then
        tail -20 "/tmp/monitor-$$.log" || true
    fi
    exit 1
fi

echo -e "${GREEN}✅ Instalação completa!${NC}"

# ==========================================
# FASE 3: EXTRAIÇÃO DE BINÁRIOS
# ==========================================
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}FASE 3: EXTRAIÇÃO DE BINÁRIOS${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo "[1/3] Localizando binários node-llama-cpp..."

# Verificar se node-llama-cpp está instalado
if [ ! -d "$NODE_LLAMA_DIR" ]; then
    echo -e "${RED}❌ node-llama-cpp NÃO encontrado!${NC}"
    echo "Não instalado ou caminho diferente"
    echo "Caminho investigado:"
    find /usr/local/lib/node_modules/openclaw -name "node-llama-cpp" -type d 2>/dev/null | head -5
    exit 1
fi

BINARIOS_ENCONTRADOS=0

# Procurar Llama.node (binário principal)
echo -e "${CYAN}Procurando Llama.node...${NC}"
LLAMA_NODE=$(find "$NODE_LLAMA_DIR" -name "Llama.node" 2>/dev/null | head -1)

if [ ! -z "$LLAMA_NODE" ]; then
    cp "$LLAMA_NODE" "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Llama.node copiado de:$LLAMA_NODE${NC}"
    BINARIOS_ENCONTRADOS=$((BINARIOS_ENCONTRADOS + 1))
else
    # Tentar outros caminhos comuns
    for path in \
        "$NODE_LLAMA_DIR/dist/bindings/bindings/arm64/linux-arm64/Llama.node" \
        "$NODE_LLAMA_DIR/dist/bindings/bindings/arm64/alpine-musl/Llama.node" \
        "$NODE_LLAMA_DIR/dist/bindings/arm64/linux-arm64/Llama.node" \
        "/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl/Llama.node"
    do
        if [ -f "$path" ]; then
            cp "$path" "$BACKUP_DIR/"
            echo -e "${GREEN}✅ Llama.node encontrado em: $path${NC}"
            BINARIOS_ENCONTRADOS=$((BINARIOS_ENCONTRADOS + 1))
            break
        fi
    done

    if [ $BINARIOS_ENCONTRADOS -eq 0 ]; then
        echo -e "${RED}❌ Llama.node NÃO encontrado${NC}"
        echo "Caminhos pesquisados:"
        find "$NODE_LLAMA_DIR" -name "*.node" 2>/dev/null
    fi
fi

# Procurar bibliotecas .so
echo ""
echo -e "${CYAN}Procurando bibliotecas .so...${NC}"
LIBS_ENCONTRADAS=0

for lib_dir in \
    "$NODE_LLAMA_DIR/llama/localBuilds/linux-arm64" \
    "$NODE_LLAMA_DIR/llama/localBuilds" \
    "/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/llama/localBuilds"
do
    if [ -d "$lib_dir" ]; then
        echo -e "  Investigando: $lib_dir"

        for lib in "$lib_dir"/lib*.so; do
            if [ -f "$lib" ]; then
                cp "$lib" "$BACKUP_DIR/"
                filename=$(basename "$lib")
                echo -e "  ${GREEN}✅ $filename copiado${NC}"
                LIBS_ENCONTRADAS=$((LIBS_ENCONTRADAS + 1))
            fi
        done
    fi
done

# Criar arquivo de metadados
echo ""
echo "[2/3] Criando arquivo de metadados..."
cat > "$BACKUP_DIR/backup-info.md" <<EOF
# Backup node-llama-cpp - Binários ARM64

Data: $(date '+%Y-%m-%d %H:%M:%S')
Sistema: PostmarketOS (Ubuntu userland)
Arquitetura: ARM64

**Binários:**
- Llama.node: $(file "$BACKUP_DIR/Llama.node" 2>/dev/null | cut -d: -f2- || "NOK")

**Bibliotecas:** $(echo "$LIBS_ENCONTRADAS")

**Versão OpenClaw:** 2026.2.2

**Próximos passos:**
1. Transferir para fork do Luan: prebuilt/linux-arm64-musl/
2. Adicionar ao package.json scripts correspondentes
3. Testar instalação do fork no ZenFone
EOF

echo -e "${GREEN}✅ Metadados criados${NC}"

echo ""
echo "[3/3] Criando arquivo de backup compactado..."
cd /tmp
tar czf node-llama-binaries.tar.gz node-llama-binaries/

TAMANHO_TAR=$(du -h node-llama-binaries.tar.gz | cut -f1)
TAMANHO_DIR=$(du -sh node-llama-binaries | cut -f1)

echo -e "${GREEN}✅ Backup compacto criado: /tmp/node-llama-binaries.tar.gz ($TAMANHO_TAR)${NC}"
echo -e "${GREEN}   Diretório: /tmp/node-llama-binaries ($TAMANHO_DIR)${NC}"

# ==========================================
# FASE 4: RELATÓRIO FINAL
# ==========================================
echo ""
echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}FASE 4: RELATÓRIO FINAL${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

echo -e "${GREEN}✅ COMPILAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo ""

echo "📋 Resumo:"
echo "  Binários: $BINARIOS_ENCONTRADOS"
echo "  Bibliotecas: $LIBS_ENCONTRADAS"
echo "  Tamanho: $TAMANHO_DIR"
echo ""

echo "📦 Arquivos:"
ls -lh "$BACKUP_DIR/"

echo ""
echo "📄 Backup compacto:"
echo "  Caminho: /tmp/node-llama-binaries.tar.gz"
echo "  Tamanho: $TAMANHO_TAR"

echo ""
echo "========================================"
echo "PRÓXIMOS PASSOS:"
echo "========================================"
echo ""
echo "1. Transferir binários para PC:"
echo -e "   ${CYAN}scp -r /tmp/node-llama-binaries luan@192.168.x.x:/path/to/save/${NC}"
echo ""
echo "2. Ou transferir via Telegram:"
echo -e "   ${CYAN}/tmp/node-llama-binaries.tar.gz${NC}"
echo ""
echo "3. No PC, preparar fork do Luan:"
echo "   - Criar: prebuilt/linux-arm64-musl/"
echo "   - Copiar binários para lá"
echo "   - Modificar package.json scripts"
echo "   - Commitar e testar"
echo ""
