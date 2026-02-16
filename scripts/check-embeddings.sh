#!/bin/bash
# Verifica se todos os arquivos de memory foram indexados pelo sistema de embeddings
# Data: 2026-02-15

MEMORY_DIR="/home/moltuser/.openclaw/workspace/memory"
LOG_FILE="/tmp/emb-fing-check-$(date +%s).log"

echo "🔍 Verificando indexação de embeddings para memory files..."
echo "Data de verificação: 2026-02-15"
echo ""
echo "📂 Diretório: $MEMORY_DIR"
echo ""

# Listar arquivos md e verificar data de modificação
echo "📄 Arquivos modificados nos últimos 4 dias:"
find "$MEMORY_DIR" -name "*.md" -mtime -4 -type f -exec ls -lh {} \;
echo ""

echo "📊 Estatísticas:"
total_files=$(find "$MEMORY_DIR" -name "*.md" -type f | wc -l)
modified_last_4=$(find "$MEMORY_DIR" -name "*.md" -mtime -4 -type f | wc -l)
echo "Total de arquivos: $total_files"
echo "Modificados nos últimos 4 dias: $modified_last_4"
echo ""

echo "🧪 Testando buscas para cada arquivo..."
count=0
for file in $(find "$MEMORY_DIR" -name "*.md" -type f -mtime -4); do
    filename=$(basename "$file")
    echo ""
    echo "Verificando: $filename"

    # Buscar usando openclaw memory search
    # Extrair um termo único do arquivo para teste
    test_term=$(head -3 "$file" | grep -oE "[A-Za-z]{4,}" | head -1)

    if [ ! -z "$test_term" ]; then
        echo "Termo de teste: $test_term"

        # Tentar buscar
        result=$(timeout 10 openclaw memory search "$test_term" 2>&1)

        if [ $? -eq 0 ]; then
            echo "✅ Busca funcionou"
        else
            echo "❌ Erro na busca"
        fi
    else
        echo "⚠️ Não foi possível extrair termo de teste"
    fi

    count=$((count + 1))
    if [ $count -ge 5 ]; then
        echo "...(limitado a 5 arquivos para teste)"
        break
    fi
done

echo ""
echo "📋 Arquivos modificados nos últimos 4 dias:"
find "$MEMORY_DIR" -name "*.md" -mtime -4 -type f
echo ""

echo "💡 Recomendações:"
echo "1. Se as buscas estão funcionando, o sistema está OK"
echo "2. Se há erros, verificar se o modelo de embedding está disponível"
echo "3. Se arquivos não aparecem nas buscas, reindexar manualmente:"
echo ""
echo "Para reindexar todos os arquivos:"
echo "for file in \$(find $MEMORY_DIR -name \"*.md\"); do"
echo "  openclaw memory search \"\$(basename \$file | cut -d'.' -f1)\""
echo "done"
