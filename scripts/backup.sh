#!/bin/sh
# Backup Atlas - Sistema de backup automático
# Roda via cron diariamente (sugestão: 2:30 AM)

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/moltuser/.openclaw/backups"
WORKSPACE="/home/moltuser/.openclaw/workspace"

# Criar diretório se não existir
mkdir -p "$BACKUP_DIR"

# Nome do arquivo de backup
BACKUP_FILE="$BACKUP_DIR/atlas_backup_$DATE.tar.gz"

# Criar backup
 tar -czf "$BACKUP_FILE" \
  -C "$WORKSPACE" \
  memory/ \
  *.md \
  skills/ \
  scripts/ \
  2>/dev/null

# Verificar se backup foi criado com sucesso
if [ -f "$BACKUP_FILE" ]; then
  echo "✅ Backup criado: $BACKUP_FILE"
  
  # Manter só os últimos 7 backups
  ls -t "$BACKUP_DIR"/atlas_backup_*.tar.gz | tail -n +8 | xargs -r rm -f
  
  echo "🧹 Backups antigos removidos (mantendo últimos 7)"
else
  echo "❌ Falha ao criar backup"
  exit 1
fi
