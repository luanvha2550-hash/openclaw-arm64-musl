#!/bin/bash
# install-with-prebuilt.sh - Usa binários prebuilt se disponíveis
# Colocar em: openclaw-arm64-musl/scripts/install-with-prebuilt.sh

echo "📦 [install] Verificando binários prebuilt..."

# Variáveis de ambiente
ARCH=$(uname -m)
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)

echo "   Arquitetura: $ARCH"
echo "   Node: $NODE_VERSION"
echo "   npm: $NPM_VERSION"

# Mapear arquitetura
case "$ARCH" in
    aarch64)
        PLATFORM="linux-arm64-musl"
        ;;
    armv7l|armv6l)
        PLATFORM="linux-arm-musl"
        ;;
    x86_64)
        PLATFORM="linux-x64"
        ;;
    *)
        echo "   ❌ Arquitetura não suportada: $ARCH"
        echo "   Procedendo com compilação padrão..."
        exit 1
        ;;
esac

# Verificar se pré-built existe
PREBUILT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../prebuilt/$PLATFORM"

if [ -d "$PREBUILT_DIR" ]; then
    echo "   ✅ Pré-built encontrado: $PREBUILT_DIR"

    # Encontrar Llama.node
    LLAMA_NODE=$(find "$PREBUILT_DIR" -name "Llama.node" -type f | head -1)

    if [ -z "$LLAMA_NODE" ]; then
        echo "   ⚠️  Llama.node não encontrado em pré-built"
        echo "   Procedendo com compilação..."
        exit 1
    fi

    echo "   ✅ Llama.node: $LLAMA_NODE"

    # Verificar libs
    LIBS_COUNT=$(find "$PREBUILT_DIR" -name "*.so" 2>/dev/null | wc -l)
    echo "   ✅ Libs encontradas: $LIBS_COUNT"

    # Copiar para o destino padrão
    DEST_DIR="node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl"

    mkdir -p "$DEST_DIR"

    echo "   📋 Copiando binários..."
    cp "$LLAMA_NODE" "$DEST_DIR/Llama.node"
    cp "$PREBUILT_DIR"/lib*.so "$DEST_DIR/" 2>/dev/null || true

    # Verificar se copiou
    if [ -f "$DEST_DIR/Llama.node" ]; then
        echo "   ✅ Binários copiados com sucesso!"
        echo "   ✅ PULANDO BUILD (NODE_LLAMA_CPP_SKIP_BUILD=true)"
        export NODE_LLAMA_CPP_SKIP_BUILD=true
        exit 0
    else
        echo "   ❌ Falha ao copiar Llama.node"
        exit 1
    fi
else
    echo "   ⚠️  Pré-built não encontrado: $PREBUILT_DIR"
    echo "   Procedendo com compilação..."
    exit 1
fi
