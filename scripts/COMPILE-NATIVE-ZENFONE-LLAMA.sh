#!/bin/bash
# COMPILE-NATIVE-ZENFONE-LLAMA.sh
# Script "Llama-inspired" - PERFEITO para compilação NATIVA ARM64 musl
# Executar DIRETAMENTE no ZenFone (SSH/ADB/Terminal)
# Data: 2026-02-15

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# ASCII Art Header
cat <<'EOF'
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   🦙 LLAMA-INSPIRED NATIVE COMPILER            ║
║                                                        ║
║   Compilação NATIVA ARM64 musl - ZenFone            ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF

echo ""
echo "Iniciando em: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ==========================================
# CONFIGURAÇÕES
# ==========================================
TIMEOUT_COMPILACAO=1800  # 30 min
RETRY_ATTEMPTS=2
BACKUP_DIR="/tmp/node-llama-native-arm64-musl"

# Verifica se está rodando no ZenFone (ARM64)
ARCH=$(uname -m)
if [ "$ARCH" != "aarch64" ]; then
    echo -e "${RED}❌ ERRO: Este script só funciona no ZenFone (ARM64)!${NC}"
    echo "   Arquitetura detectada: $ARCH"
    echo "   Execute diretamente no ZenFone via SSH/ADB"
    exit 1
fi

echo -e "${GREEN}✅ Arquitetura ARM64 detectada${NC}"
echo ""

# ==========================================
# FASE 1: PREPARAÇÃO
# ==========================================
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}FASE 1: PREPARAÇÃO DO AMBIENTE${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# Step 1: NPM Shell Fix (CRITICAL for PostmarketOS)
echo -e "[1/6] Corrigindo configuração npm shell..."
npm config set script-shell /bin/sh 2>&1
SHELL_CONFIG=$(npm config get script-shell)
echo -e "${GREEN}✅ Shell config: $SHELL_CONFIG${NC}"

# Step 2: Verificar recursos disponíveis
echo ""
echo -e "[2/6] Verificando recursos..."
RAM_AVAILABLE=$(free | awk '/Mem:/ {printf "%.0f", $7/1024}')
DISK_AVAILABLE=$(df -m / | awk 'NR==2 {print $4}')

echo "   RAM disponível: $RAM_AVAILABLE MB"
echo "   Disco disponível: $DISK_AVAILABLE MB"

if [ "$RAM_AVAILABLE" -lt 400 ]; then
    echo -e "${RED}❌ RAM insuficiente (< 400MB)!${NC}"
    echo "   Feche outros apps e tente novamente"
    exit 1
fi

if [ "$DISK_AVAILABLE" -lt 1500 ]; then
    echo -e "${RED}❌ Disco insuficiente (< 1.5GB)!${NC}"
    echo "   Libere espaço e tente novamente"
    exit 1
fi

echo -e "${GREEN}✅ Recursos OK${NC}"

# Step 3: Limpando instalação anterior
echo ""
echo -e "[3/6] Limpando instalação anterior..."
npm uninstall -g openclaw 2>&1 | head -3
sudo rm -rf /usr/local/lib/node_modules/openclaw 2>/dev/null
rm -rf ~/.npm-cache 2>/dev/null
echo -e "${GREEN}✅ Limpeza concluída${NC}"

# Step 4: Criar diretórios
echo ""
echo -e "[4/6] Criando diretórios de trabalho..."
mkdir -p "$BACKUP_DIR"
mkdir -p ~/.node-gyp
echo -e "${GREEN}✅ Diretórios criados${NC}"

# Step 5: Atualizar node-gyp se necessário
echo ""
echo -e "[5/6] Verificando node-gyp..."
if ! command -v node-gyp &> /dev/null; then
    echo "Instalando node-gyp..."
    npm i -g node-gyp
fi
NODE_GYP_VERSION=$(node-gyp --version 2>/dev/null | head -1)
echo -e "${GREEN}✅ node-gyp: $NODE_GYP_VERSION${NC}"

# Step 6: Limpar cache npm
echo ""
echo -e "[6/6] Limpando cache npm..."
npm cache clean --force
echo -e "${GREEN}✅ Cache limpo${NC}"

# ==========================================
# FASE 2: COMPILAÇÃO NATIVA
# ==========================================
echo ""
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${CYAN}FASE 2: COMPILAÇÃO NATIVA (NODE-LLAMA-CPP)${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}⏱️  Tempo estimado: 15-30 minutos${NC}"
echo -e "${YELLOW}⚠️  Consumo alto: CPU + RAM${NC}"
echo -e "${YELLOW}⚠️  NÃO FECHE ESTE TERMINAL!${NC}"
echo ""

read -p "Pressione ENTER para continuar ou Ctrl+C para cancelar..."

INSTALL_SUCCESS=false
for ATTEMPT in $(seq 1 $RETRY_ATTEMPTS); do
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${CYAN}TENTATIVA $ATTEMPT/$RETRY_ATTEMPTS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""

    echo -e "${CYAN}[+] Executando npm i -g openclaw@2026.2.2...${NC}"
    echo ""

    # Execute install with timeout and progress tracking
    START_TIME=$(date +%s)

    if timeout $TIMEOUT_COMPILACAO \
        bash -c "npm i -g openclaw@2026.2.2 2>&1 | tee /tmp/npm-install.log" ; then

        INSTALL_SUCCESS=true
        break

    else
        EXIT_CODE=$?
        END_TIME=$(date +%s)
        ELAPSED=$((END_TIME - START_TIME))

        echo ""
        echo -e "${RED}❌ FALHA NA INSTALAÇÃO${NC}"
        echo "   Exit code: $EXIT_CODE"
        echo "   Tempo decorrido: $ELAPSED segundos"

        if [ $EXIT_CODE -eq 124 ]; then
            echo -e "${YELLOW}⚠️  TIMEOUT (mais de 30 minutos)${NC}"
            echo "   A compilação está demorando muito"
        fi

        # Show last 20 lines of log
        echo ""
        echo -e "${CYAN}[+] Últimas 20 linhas do log:${NC}"
        tail -20 /tmp/npm-install.log 2>/dev/null || echo "(Log não disponível)"

        if [ $ATTEMPT -lt $RETRY_ATTEMPTS ]; then
            echo ""
            echo -e "${YELLOW}Tentando novamente em 5 segundos...${NC}"
            sleep 5
        fi
    fi
done

if [ "$INSTALL_SUCCESS" = false ]; then
    echo ""
    echo -e "${RED}═══════════════════════════════════════════${NC}"
    echo -e "${RED}❌ FALHA APÓS $RETRY_ATTEMPTS TENTATIVAS${NC}"
    echo -e "${RED}═══════════════════════════════════════════${NC}"
    echo ""
    echo "Diagnóstico:"
    echo "  1. Verifique se node-gyp está instalado: npm i -g node-gyp"
    echo "  2. Verifique RAM livre: free -h"
    echo "  3. Verifique disco: df -h /"
    echo "  4. Log completo: /tmp/npm-install.log"
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ INSTALAÇÃO CONCLUÍDA COM SUCESSO!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════${NC}"
echo ""

# ==========================================
# FASE 3: EXTRAIÇÃO DE BINÁRIOS
# ==========================================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}FASE 3: LOCALIZANDO E EXTRAINDO BINÁRIOS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

NODE_LLAMA_PATH="/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp"

if [ ! -d "$NODE_LLAMA_PATH" ]; then
    echo -e "${RED}❌ node-llama-cpp NÃO encontrado em $NODE_LLAMA_PATH${NC}"
    echo ""
    echo "Procurando em outros locais..."
    find /usr/local/lib/node_modules/openclaw -name "node-llama-cpp" -type d 2>/dev/null | head -5
    exit 1
fi

echo -e "${GREEN}✅ node-llama-cpp encontrado${NC}"
echo "   Caminho: $NODE_LLAMA_PATH"
echo ""

# Copy binaries
echo "[1/5] Copiando Llama.node..."
BINARIES_COPIED=0

# Search for Llama.node in all possible locations
for LLAMA_NODE in \
    "$NODE_LLAMA_PATH/dist/bindings/bindings/arm64/linux-arm64/Llama.node" \
    "$NODE_LLAMA_PATH/dist/bindings/bindings/arm64/alpine-musl/Llama.node" \
    "$NODE_LLAMA_PATH/dist/bindings/arm64/linux-arm64/Llama.node" \
    "$NODE_LLAMA_PATH/build/Release/Llama.node" \
    "$NODE_LLAMA_PATH/bin/Release/Llama.node"
do
    if [ -f "$LLAMA_NODE" ]; then
        cp "$LLAMA_NODE" "$BACKUP_DIR/"
        echo -e "${GREEN}✅ Llama.node copiado${NC}"
        echo "   De: $LLAMA_NODE"
        echo "   Para: $BACKUP_DIR/Llama.node"
        file "$BACKUP_DIR/Llama.node"
        BINARIES_COPIED=$((BINARIES_COPIED + 1))
        break
    fi
done

if [ $BINARIES_COPIED -eq 0 ]; then
    echo -e "${RED}❌ Llama.node NÃO encontrado!${NC}"
    echo "Buscando todos os arquivos .node..."
    find "$NODE_LLAMA_PATH" -name "*.node" 2>/dev/null
fi

echo ""
echo "[2/5] Copiando bibliotecas .so..."
LIBS_COPIED=0

for LIB_PATH in \
    "$NODE_LLAMA_PATH/llama/localBuilds" \
    "$NODE_LLAMA_PATH/llama" \
    "$NODE_LLAMA_PATH/build"
do
    if [ -d "$LIB_PATH" ]; then
        echo "   Analisando: $LIB_PATH"

        # Remove old files
        rm -f "$BACKUP_DIR"/lib*.so

        # Copy new libs
        for LIB in "$LIB_PATH"/lib*.so; do
            if [ -f "$LIB" ]; then
                cp "$LIB" "$BACKUP_DIR/"
                LIB_NAME=$(basename "$LIB")
                LIB_SIZE=$(du -h "$LIB" | cut -f1)
                echo "   ${GREEN}✅ $LIB_NAME ($LIB_SIZE)${NC}"
                LIBS_COPIED=$((LIBS_COPIED + 1))
            fi
        done

        if [ $LIBS_COPIED -gt 0 ]; then
            break
        fi
    fi
done

# Copy any additional .so files
echo ""
echo "[3/5] Procurando mais libs .so..."
ADDITIONAL_LIBS=$(find "$NODE_LLAMA_PATH" -name "*.so" 2>/dev/null | head -10)

for ADDITIONAL_LIB in $ADDITIONAL_LIBS; do
    LIB_NAME=$(basename "$ADDITIONAL_LIB")
    if [ ! -f "$BACKUP_DIR/$LIB_NAME" ]; then
        cp "$ADDITIONAL_LIB" "$BACKUP_DIR/"
        echo "   📦 $LIB_NAME (adicional)"
        LIBS_COPIED=$((LIBS_COPIED + 1))
    fi
done

echo ""
echo "[4/5] Criando metadados..."
cat > "$BACKUP_DIR/METADATA.md" <<EOF
# Binários node-llama-cpp - ARM64 musl (NATIVO)

**Data**: $(date '+%Y-%m-%d %H:%M:%S')
**Metodo**: Compilação NATIVA no ZenFone (PostmarketOS)
**Arquitetura**: ARM64 $(uname -m)
**Kernel**: $(uname -r)
**Node**: $(node --version)
**npm**: $(npm --version)

---

## Binários

| Arquivo | Tamanho | Descrição |
|---------|---------|-----------|
| $(file -b "$BACKUP_DIR"/Llama.node 2>/dev/null || echo "N/A") | $(du -h "$BACKUP_DIR"/Llama.node 2>/dev/null | cut -f1 || echo "N/A") | Binário principal |

---

## Bibliotecas

Total: $LIBS_COPIED

\`\`\`
$(ls -lh "$BACKUP_DIR"/lib*.so 2>/dev/null)
\`\`\`

---

## Próximos Passos

1. Transferir este diretório para PC:
   \`\`\`
   scp -r /tmp/node-llama-native-arm64-musl luan@192.168.x.x:/path/to/fork/prebuilt/linux-arm64-musl/
   \`\`\`

2. Commit no fork do Luan: luanvha2550-hash/openclaw-arm64-musl

3. Testar no ZenFone:
   \`\`\`
   npm i -g --no-scripts luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl
   \`\`\`

**Compilado por:** Llama-inspired Compiler v1.0
EOF

echo -e "${GREEN}✅ Metadados criados${NC}"

echo ""
echo "[5/5] Copiando logs úteis..."
cp /tmp/npm-install.log "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✅ Logs copiados${NC}"

# ==========================================
# FASE 4: EMPACOTAMENTO
# ==========================================
echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}FASE 4: EMPACOTANDO BINÁRIOS${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

cd /tmp
mkdir -p node-llama-native-arm64-musl
cp -r /tmp/node-llama-native-arm64-musl/* node-llama-native-arm64-musl/

# Create tar.gz
echo "Criando arquivo compacto..."
tar czf node-llama-native-arm64-musl.tar.gz node-llama-native-arm64-musl/

ARCHIVE_SIZE=$(du -h node-llama-native-arm64-musl.tar.gz | cut -f1)
DIR_SIZE=$(du -sh node-llama-native-arm64-musl | cut -f1)

echo -e "${GREEN}✅ Arquivo criado${NC}"
echo "   └─ /tmp/node-llama-native-arm64-musl.tar.gz ($ARCHIVE_SIZE)"
echo "   └─ Diretório: /tmp/node-llama-native-arm64-musl ($DIR_SIZE)"

# ==========================================
# FASE 5: RELATÓRIO FINAL
# ==========================================
echo ""
echo ""
cat <<'EOF'
╔════════════════════════════════════════════════════════╗
║                                                        ║
║           ✅ COMPILAÇÃO CONCLUÍDA! ✅                  ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
echo ""

echo "📋 RESUMO:"
echo "   └─ Binários copiados: $BINARIES_COPIED"
echo "   └─ Bibliotecas: $LIBS_COPIED"
echo "   └─ Tamanho compactado: $ARCHIVE_SIZE"
echo ""

echo "📦 ARQUIVO FINAL:"
echo "   └─ /tmp/node-llama-native-arm64-musl.tar.gz"
echo ""

echo "🔍 CONTEÚDO:"
ls -lh /tmp/node-llama-native-arm64-musl/ | tail -10

echo ""
echo "════════════════════════════════════════════════════════════"
echo "📤 PRÓXIMOS PASSOS:"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "🚀 OPÇÃO 1: Transferir para PC via SCP"
cat <<EOF
   scp /tmp/node-llama-native-arm64-musl.tar.gz luan@YOUR_PC_IP:/path/to/
EOF

echo ""
echo "📤 OPÇÃO 2: Transferir via Telegram"
echo "   Envie: /tmp/node-llama-native-arm64-musl.tar.gz"

echo ""
echo "🚀 OPÇÃO 3: USB"
echo "   1. Copie arquivo para Storage/Download/"
echo "   2. Desplug e conecte no PC"

echo ""
echo "════════════════════════════════════════════════════════════"
echo "No PC, execute:"
echo "   1. Extraia tar.gz"
echo "   2. Copie para: fork/prebuilt/linux-arm64-musl/"
echo "   3. Teste no ZenFone"
echo "════════════════════════════════════════════════════════════"
echo ""

echo -e "${GREEN}✨ Compilação NATIVA ARM64 musl concluída! ✨${NC}"
echo ""

# Fim
