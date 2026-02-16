#!/bin/bash
# ========================================
# BACKUP AUTOMÁTICO - OpenClaw → SD Card
# Executado diariamente via cron
# ========================================

DATE=$(date +%Y%m%d)
TIME=$(date +%H%M%S)
BACKUP_DIR="/mnt/sdcard/openclaw-backups"
WORKSPACE="/home/moltuser/.openclaw/workspace"
CONFIG_DIR="/home/moltuser/.openclaw"
LOG_FILE="/home/moltuser/.openclaw/logs/backup.log"

# Criar diretório de backup se não existir
mkdir -p "$BACKUP_DIR"

# Log início
echo "[$(date)] Iniciando backup..." >> "$LOG_FILE"

# Criar backup incremental
BACKUP_FILE="$BACKUP_DIR/openclaw-backup-$DATE.tar.gz"

# Arquivos essenciais para backup
tar -czf "$BACKUP_FILE" \
  --exclude='node_modules' \
  --exclude='.git' \
  --exclude='*.log' \
  --exclude='logs/*' \
  -C "$CONFIG_DIR" \
  workspace/ \
  agents/ \
  2>> "$LOG_FILE"

# Verificar sucesso
if [ $? -eq 0 ]; then
  SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo "[$(date)] ✅ Backup criado: $BACKUP_FILE ($SIZE)" >> "$LOG_FILE"
  
  # Manter apenas últimos 14 backups
  ls -t "$BACKUP_DIR"/openclaw-backup-*.tar.gz | tail -n +15 | xargs rm -f 2>/dev/null
  
  # Remover backups antigos (mais de 30 dias)
  find "$BACKUP_DIR" -name "*.tar.gz" -mtime +30 -delete 2>/dev/null
  
  echo "[$(date)] Backups ativos: $(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)" >> "$LOG_FILE"
else
  echo "[$(date)] ❌ Erro no backup!" >> "$LOG_FILE"
  exit 1
fi

# Backup adicional do banco de dados principal (mais frequente)
DB_BACKUP="$BACKUP_DIR/atlas-db-$DATE-$TIME.db"
if [ -f "$WORKSPACE/database/projects.db" ]; then
  cp "$WORKSPACE/database/projects.db" "$DB_BACKUP"
  gzip -f "$DB_BACKUP"
  echo "[$(date)] 📦 DB backup: $DB_BACKUP.gz" >> "$LOG_FILE"
fi

echo "[$(date)] Backup finalizado com sucesso!" >> "$LOG_FILE"
