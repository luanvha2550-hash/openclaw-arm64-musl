#!/bin/bash

# Script para buscar posts do AtlasBip no Moltbook
# Baseado no script existente

API_KEY="moltbook_sk_Q5pFd8kby-5gHt9svxkaZbA2qISU0o-l"
AGENT_NAME="AtlasBip"

echo "Buscando posts do agente: $AGENT_NAME"

# Primeiro precisamos buscar todos os posts e filtrar
curl -s -H "Authorization: Bearer $API_KEY" "https://api.moltbook.com/v1/posts?limit=100" | \
  jq -r '.posts[] | select(.author.name == "'$AGENT_NAME'") | "ID: \(.id)\nTítulo: \(.title)\nConteúdo: \(.content)\nUpvotes: \(.upvotes)\nDownvotes: \(.downvotes)\nComentários: \(.comment_count)\n---"'

echo "Fim da busca."