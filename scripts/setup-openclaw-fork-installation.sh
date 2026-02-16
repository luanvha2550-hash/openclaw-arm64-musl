#!/bin/bash
# setup-openclaw-fork-installation.sh
# Configura ambiente para instalar OpenClaw fork no PostmarketOS
# Baseado em diagnóstico Gemini 3
# Data: 2026-02-15

set -e

echo "🔧 SETUP AMBIENTE - OpenClaw Fork Installation"
echo "Baseado em: Diagnóstico Gemini 3 (PostmarketOS/Alpine)"
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "PASSO 1: Corrigir erro 'spawn sh'"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "Configurando npm para usar shell correto..."
npm config set script-shell /bin/sh

CURRENT_SHELL=$(npm config get script-shell)
echo -e "✅ Configurado: $CURRENT_SHELL"

echo ""
echo "Verificando se git está instalado..."
if ! command -v git &> /dev/null; then
    echo "⚠️  Git não instalado. Instalando..."
    apk add git
else
    echo "✅ Git já instalado"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "PASSO 2: Estratégia Pre-bake (Pré-compilação llama.cpp)"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "Objetivo: Pre-compilar node-llama-cpp UMA VEZ e commitar no fork"
echo ""

# Opções
echo "Escolha método de compilação:"
echo ""
echo "1. Compilar no ZenFone (vai levar ~15-30 min, usa muita RAM/CPU)"
echo "2. Usar compilação existente (se já tiver binários salvos)"
echo "3. Aguardar - Usar Docker Alpine/ARM64 (futuro)"
echo "4. Tentar instalação com --no-scripts (pule compilação por enquanto)"
echo ""
read -p "Opção [1-4]: " choice

case $choice in
    1)
        echo ""
        echo "⚠️  ATENÇÃO: Compilação vai demorar..."
        echo "   - Tempo estimado: 15-30 min"
        echo "   - RAM necessária: ~500 MB"
        echo "   - CPU: 100% durante build"
        echo ""
        read -p "Continuar? (s/N): " confirm
        if [[ $confirm =~ ^[Ss]$ ]]; then
            echo "Iniciando compilação..."
            echo "(Não implementado ainda - chamar agente Llama para detalhes)"
        else
            echo "Cancelado."
            exit 0
        fi
        ;;

    2)
        echo ""
        echo "📦 Procurando binários pré-compilados salvos..."
        BACKUP_DIR="/tmp/node-llama-cpp-backup"
        if [ -d "$BACKUP_DIR" ] && [ -f "$BACKUP_DIR/Llama.node" ]; then
            echo -e "✅ Binários encontrados em: $BACKUP_DIR"
            echo ""
            echo "Próximo passo: Preparar fork do Luan para usar esses binários"
            echo ""
            echo "TODO:"
            echo "1. Copiar binários para fork (luanvha2550-hash/openclaw-arm64-musl)"
            echo "2. Criar pasta: /prebuilt/linux-arm64-musl/"
            echo "3. Modificar package.json para usar binários pré-compilados"
        else
            echo "❌ Nenhum binário encontrado"
            echo ""
            echo "Precisa compilar antes ou obter de outra fonte"
        fi
        ;;

    3)
        echo ""
        echo "Agendado: Usar Docker Alpine/ARM64 (futuro)"
        echo "   - Precisa ter acesso a máquina x86_64 com Docker"
        echo "   - Ou aguardar compilação completar no ZenFone"
        ;;

    4)
        echo ""
        echo "🚀 Instalando com --no-scripts (pular compilação)..."
        echo ""
        echo "Isso vai instalar OpenClaw mas node-llama-cpp NÃO vai funcionar"
        echo "Features LLM locais estarão indisponíveis"
        echo ""
        read -p "Continuar? (s/N): " confirm
        if [[ $confirm =~ ^[Ss]$ ]]; then
            echo "Removendo instalação corrompida..."
            npm uninstall -g openclaw 2>/dev/null || true
            sudo rm -rf /usr/local/lib/node_modules/openclaw 2>/dev/null || true

            echo ""
            echo "Instalando..."
            npm i -g --no-scripts luanvha2550-hash/openclaw-arm64-musl#v2026.2.2-arm64-musl

            echo ""
            echo "Verificando..."
            if [ -f "/usr/local/lib/node_modules/openclaw/package.json" ]; then
                echo "✅ Instalação basicamente completa!"
                echo ""
                echo "⚠️  NOTA: node-llama-cpp não instalado (sem compilação)"
            else
                echo "❌ Instalação falhou"
                exit 1
            fi
        else
            echo "Cancelado."
        fi
        ;;

    *)
        echo "Opção inválida"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "CONCLUSÃO"
echo "═══════════════════════════════════════════════════════════"

echo ""
if npm config get script-shell | grep -q "/bin/sh"; then
    echo -e "✅ PASSO 1: Shell configurado corretamente"
else
    echo "❌ PASSO 1: Falha na configuração do shell"
fi

echo ""
echo "📋 Resumo:"
echo "1. Erro 'spawn sh' corrigido com: npm config set script-shell /bin/sh"
echo "2. Próximo: Pre-bake (pré-compilar) node-llama-cpp"
echo "3. Compilar uma vez, commitar no fork, usar sempre"
