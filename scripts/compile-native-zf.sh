#!/bin/bash
# compile-native.sh - Compila node-llama-cpp nativo no ZenFone
# Data: 2026-02-15

set -e

echo "🔧 Compilando node-llama-cpp nativo ARM64 no ZenFone"
echo "================================================"
echo ""

# Fix shell
echo "[1/4] Corrigido shell config..."
npm config set script-shell /bin/sh

# Verificar recursos
echo ""
echo "[2/4] Verificando recursos disponíveis..."
echo "RAM:"
free -h
echo "Disco:"
df -h /
echo ""

read -p "Continuar? (S/N): " confirm
if [[ ! $confirm =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
fi

# Limpar instalação anterior
echo ""
echo "[3/4] Limpando instalação anterior..."
npm uninstall -g openclaw 2>/dev/null || true
sudo rm -rf /usr/local/lib/node_modules/openclaw 2>/dev/null || true

# Instalar OpenClaw (vai compilar node-llama-cpp)
echo ""
echo "[3/4] Instalando OpenClaw (compilando node-llama-cpp)..."
echo "⏱️  Tempo estimado: 15-30 min"
echo "⚠️  Vai usar muita CPU e RAM"
echo "Pressione Ctrl+C para cancelar a qualquer momento"
echo ""

npm i -g openclaw@2026.2.2 || {
    echo "❌ Compilação falhou"
    exit 1
}

echo ""
echo "✅ Instalação completa!"

# Copiar binários
echo "[4/4] Copiando binários compilados..."
mkdir -p /tmp/node-llama-binaries

BINARIO="/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/dist/bindings/bindings/arm64/linux-arm64/Llama.node"

if [ -f "$BINARIO" ]; then
    cp "$BINARIO" /tmp/node-llama-binaries/
    echo "✅ Llama.node copiado"
else
    echo "❌ Binário não encontrado em: $BINARIO"
    echo "Caminhos disponíveis:"
    find /usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp -name "*.node" 2>/dev/null
    exit 1
fi

# Encontrar e copiar libs
LIB_DIR="/usr/local/lib/node_modules/openclaw/node_modules/node-llama-cpp/llama/localBuilds/linux-arm64"
if [ -d "$LIB_DIR" ]; then
    find "$LIB_DIR" -name "*.so" -exec cp {} /tmp/node-llama-binaries/ \; 2>/dev/null || \
    echo "⚠️  Nenhuma .so encontrada (pode estar em outro local)"
fi

echo ""
echo "✅ Binários compilados e salvos em: /tmp/node-llama-binaries"
echo ""
echo "Conteúdo:"
ls -lh /tmp/node-llama-binaries/

TAMANHO=$(du -sh /tmp/node-llama-binaries | cut -f1)
echo ""
echo "Tamanho: $TAMANHO"

echo ""
echo "================================================"
echo "PRÓXIMOS PASSOS:"
echo "================================================"
echo ""
echo "1. Transferir /tmp/node-llama-binaries para o PC:"
echo "   scp -r /tmp/node-llama-binaries luan@192.168.x.x:/path/to/save/"
echo ""
echo "2. No PC, preparar fork do Luan:"
echo "   - Criar: prebuilt/linux-arm64-musl/"
echo "   - Copiar binários para lá"
echo "   - Commitar e testar"
echo ""
echo "3. No ZenFone, testar instalação do fork:"
echo "   npm i -g luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl"
