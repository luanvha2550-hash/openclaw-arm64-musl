#!/bin/bash
# postinstall-verify.sh - Verifica se instalação funcionou
# Colocar em: openclaw-arm64-musl/scripts/postinstall-verify.sh

echo "🔍 [postinstall] Verificando instalação..."

ARCH=$(uname -m)
echo "   Arquitetura: $ARCH"

# Verificar Llama.node
NODE_LLAMA="node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl/Llama.node"
if [ -f "$NODE_LLAMA" ]; then
    echo "✅ Llama.node encontrado"
    file "$NODE_LLAMA"
else
    # Tentar outros caminhos
    for path in \
        "node_modules/openclaw/node_modules/node-llama-cpp/dist/bindings/bindings/arm64/alpine-musl/Llama.node" \
        "node_modules/node-llama-cpp/bin/Release/Llama.node"
    do
        if [ -f "$path" ]; then
            echo "✅ Llama.node encontrado (alternativo): $path"
            break
        fi
    done
fi

# Verificar se é binário ELF ARM64
if command -v file &> /dev/null; then
    if file $NODE_LLAMA 2>/dev/null | grep -q "ELF.*ARM.*aarch64"; then
        echo "✅ Binário ARM64 válido"
    elif file $(find . -name "Llama.node" | head -1) 2>/dev/null | grep -q "ELF.*ARM.*aarch64"; then
        echo "✅ Binário ARM64 válido (encontrado)}"
    else
        echo "⚠️  Binário não é ARM64 ou não encontrado"
    fi
fi

# Verificar libs
LIBS=$(find node_modules -name "*.so" 2>/dev/null | wc -l)
echo "✅ Bibliotecas encontradas: $LIBS"

# Mostrar arquivos principais
echo ""
echo "📋 Arquivos principais:"
find . -name "Llama.node" 2>/dev/null | head -5
find . -name "libllama*.so" 2>/dev/null | head -5

echo ""
echo "✅ Verificação concluída!"
exit 0
