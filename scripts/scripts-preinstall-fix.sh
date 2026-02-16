#!/bin/bash
# preinstall-fix.sh - Corrige erro "spawn sh ENOENT" no PostmarketOS
# Colocar em: openclaw-arm64-musl/scripts/preinstall-fix.sh

echo "🔧 [preinstall] Corrigindo configuração de shell..."

# Detectar sistema
if [ -n "$OPENCLAW_SKIP_SHELL_FIX" ]; then
    echo "   Ignorando shell fix (variável definida)"
    exit 0
fi

# Forçar /bin/sh (fix para PostmarketOS BusyBox)
npm config set script-shell /bin/sh 2>/dev/null || true

# Verificar se /bin/sh existe
if [ ! -x /bin/sh ]; then
    echo "   ⚠️  /bin/sh não encontrado, tentando /bin/bash..."
    npm config set script-shell /bin/bash 2>/dev/null || true
fi

# Mostrar configuração atual
CURRENT_SHELL=$(npm config get script-shell 2>/dev/null)
echo "   ✅ Shell configurado: $CURRENT_SHELL"

# Detectar PostmarketOS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "postmarketos" ] || [ "$ID" = "alpine" ]; then
        echo "   ✅ Detectado: $NAME (musl libc)"
        export NODE_LLAMA_CPP_SKIP_DOWNLOAD=true
    fi
fi

exit 0
