#!/bin/bash
# AUTOMATED FORK SETUP - VAI FAZER TUDO AUTOMATICAMENTE
# Data: 2026-02-15

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   🤖 AUTOMATED FORK SETUP                    ║"
echo "║   Preparando fork do Luan AUTOMATICAMENTE    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# PASSO 1: Verificar se compilação terminou
echo -e "${CYAN}[1/5] Verificando compilação no ZenFone...${NC}"

if [ -f /tmp/b.tar.gz ]; then
    echo -e "${GREEN}✅ /tmp/b.tar.gz encontrado!${NC}"
    tar tzf /tmp/b.tar.gz 2>/dev/null | head -10
else
    # Tentar outros possíveis nomes
    for file in /tmp/*.tar.gz /tmp/llama-*.tar.gz; do
        if [ -f "$file" ]; then
            echo -e "${GREEN}✅ Encontrado: $file${NC}"
            ln -sf "$file" /tmp/b.tar.gz
            break
        fi
    done
fi

if [ ! -f /tmp/b.tar.gz ]; then
    echo -e "${YELLOW}⚠️  Nenhum arquivo de binários encontrado${NC}"
    echo "   Tentando buscar diretamente..."

    # Buscar binários no local padrão
    if [ -f /tmp/llama-binarios/Llama.node ] || [ -f /home/$USER/node_modules/node-llama-cpp/build/Release/Llama.node ]; then
        echo -e "${GREEN}✅ Binários encontrados! Criando tar.gz...${NC}"
        mkdir -p /tmp/auto-binaries

        # Copiar de múltiplas localizações
        for src in \
            /tmp/llama-binarios/Llama.node \
            /home/$USER/node_modules/node-llama-cpp/build/Release/Llama.node \
            /usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/build/Release/Llama.node
        do
            if [ -f "$src" ]; then
                cp "$src" /tmp/auto-binaries/
                echo -e "${GREEN}   Copiado: $src${NC}"
                break
            fi
        done

        # Copiar libs
        for dir in \
            /tmp/llama-binarios \
            /home/$USER/node_modules/node-llama-cpp/llama/localBuilds \
            /usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/llama/localBuilds
        do
            if [ -d "$dir" ]; then
                find "$dir" -name "*.so" 2>/dev/null | xargs -I{} cp {} /tmp/auto-binaries/
            fi
        done

        cd /tmp
        tar czf b.tar.gz auto-binaries/
    else
        echo -e "${RED}❌ Nenhum binário encontrado!${NC}"
        echo "   Execute o comando de compilação primeiro"
        exit 1
    fi
fi

# PASSO 2: Extrair binários
echo ""
echo -e "${CYAN}[2/5] Extraindo binários...${NC}"
mkdir -p /tmp/extracted-binaries
cd /tmp
tar xzf b.tar.gz -C /tmp/extracted-binaries/ 2>/dev/null || true

# Encontrar Llama.node
LLAMA_NODE=$(find /tmp/extracted-binaries -name "Llama.node" -type f 2>/dev/null | head -1)

if [ -z "$LLAMA_NODE" ]; then
    echo -e "${RED}❌ Llama.node não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Llama.node: $LLAMA_NODE${NC}"
file "$LLAMA_NODE"

# PASSO 3: Organizar fork
echo ""
echo -e "${CYAN}[3/5] Organizando fork do Luan...${NC}"

# Criar estrutura
FORK_DIR="/tmp/openclaw-arm64-musl-fork"
rm -rf "$FORK_DIR"
mkdir -p "$FORK_DIR"

cd "$FORK_DIR"

# Clonar fork (simulado - na realidade você faria git clone)
mkdir -p prebuilt/linux-arm64-musl
mkdir -p scripts

# Copiar binários
cp "$LLAMA_NODE" prebuilt/linux-arm64-musl/
find /tmp/extracted-binaries -name "*.so" -type f 2>/dev/null | xargs -I{} cp {} prebuilt/linux-arm64-musl/

echo -e "${GREEN}✅ Binários copiados${NC}"
ls -lh prebuilt/linux-arm64-musl/

# Copiar scripts
cp /home/moltuser/.openclaw/workspace/fork-preparation/scripts-preinstall-fix.sh scripts/preinstall-fix.sh
cp /home/moltuser/.openclaw/workspace/fork-preparation/scripts-install-with-prebuilt.sh scripts/install-with-prebuilt.sh

chmod +x scripts/*.sh

echo -e "${GREEN}✅ Scripts copiados${NC}"

# Criar package.json atualizado
cat > package.json << 'EOF'
{
  "name": "openclaw-arm64-musl",
  "version": "2026.2.2-arm64-musl",
  "description": "OpenClaw with ARM64 musl prebuilt binaries for PostmarketOS",
  "scripts": {
    "preinstall": "bash scripts/preinstall-fix.sh || true",
    "install": "bash scripts/install-with-prebuilt.sh || npm install --ignore-scripts",
    "test": "echo \"OK\""
  },
  "keywords": [
    "openclaw",
    "arm64",
    "musl",
    "postmarketos"
  ],
  "author": "luanvha2550-hash",
  "license": "MIT"
}
EOF

echo -e "${GREEN}✅ package.json criado${NC}"

# PASSO 4: Preparar tar final
echo ""
echo -e "${CYAN}[4/5] Empacotando fork ready...${NC}"
cd /tmp
tar czf openclaw-arm64-musl-ready.tar.gz openclaw-arm64-musl-fork/

SIZE=$(du -h openclaw-arm64-musl-ready.tar.gz | cut -f1)

echo -e "${GREEN}✅ Fork empacotado:${NC}"
echo "   /tmp/openclaw-arm64-musl-ready.tar.gz ($SIZE)"

# PASSO 5: Finalizar
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ AUTOMATED SETUP CONCLUÍDO! ✅                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

echo "📦 FORK PRONTO:"
echo "   Localização: /tmp/openclaw-arm64-musl-ready.tar.gz"
echo "   Tamanho: $SIZE"
echo ""

echo "📋 Estrutura criada:"
echo ""
tree "$FORK_DIR" -L 3 2>/dev/null || ls -R "$FORK_DIR"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🚀 PRÓXIMO PASSO:"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "No PC, execute:"
echo ""
echo "1. Receber arquivo:"
echo "   scp /tmp/openclaw-arm64-musl-ready.tar.gz luan@192.168.x.x:/path/to/"
echo ""
echo "2. Clonar fork:"
echo "   git clone git@github.com:luanvha2550-hash/openclaw-arm64-musl.git"
echo "   cd openclaw-arm64-musl"
echo ""
echo "3. Extrair:"
echo "   tar xzf openclaw-arm64-musl-ready.tar.gz"
echo "   cp -r openclaw-arm64-musl-fork/* ."
echo ""
echo "4. Commitar:"
echo "   git add ."
echo "   git commit -m 'feat: add ARM64 musl prebuilt binaries'"
echo "   git push origin main"
echo ""
echo "5. Testar no ZenFone:"
echo "   npm i -g --no-scripts luanvha2550-hash/openclaw-arm64-musl"
echo ""
