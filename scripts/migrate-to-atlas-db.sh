#!/bin/bash
# ========================================
# MIGRAÇÃO → ATLAS.DB
# Unifica os dois projects.db em um único banco
# ========================================

WORKSPACE="/home/moltuser/.openclaw/workspace"
DB_DIR="$WORKSPACE/database"
OLD_DB1="$DB_DIR/projects.db"
OLD_DB2="$WORKSPACE/projects/database/projects.db"
NEW_DB="$DB_DIR/atlas.db"
SCHEMA="$DB_DIR/atlas-schema.sql"

echo "🔄 Iniciando migração para ATLAS.DB..."

# Backup dos bancos antigos
echo "📦 Criando backup dos bancos antigos..."
mkdir -p "$DB_DIR/backup"
cp "$OLD_DB1" "$DB_DIR/backup/projects-db1-$(date +%Y%m%d).db" 2>/dev/null
cp "$OLD_DB2" "$DB_DIR/backup/projects-db2-$(date +%Y%m%d).db" 2>/dev/null

# Criar novo banco com schema
echo "📋 Criando novo ATLAS.DB com schema v2.0..."
sqlite3 "$NEW_DB" < "$SCHEMA"

# Migrar dados do banco MAIS RECENTE (projects/database/projects.db)
echo "📥 Migrando dados do banco mais recente ($OLD_DB2)..."

# Migrar projetos
sqlite3 "$OLD_DB2" "SELECT id, name, description, status, priority, created_at, updated_at FROM projects;" 2>/dev/null | while IFS='|' read id name desc status priority created updated; do
  sqlite3 "$NEW_DB" "INSERT OR IGNORE INTO projects (name, description, status, priority, created_at, updated_at) VALUES ('$name', '$desc', '$status', '$priority', '$created', '$updated');"
done

# Migrar contatos
sqlite3 "$OLD_DB2" "SELECT name, phone, email, relationship, status, notes, last_contact, created_at, updated_at FROM contacts;" 2>/dev/null | while IFS='|' read name phone email rel status notes last created updated; do
  # Escapar aspas simples
  notes=$(echo "$notes" | sed "s/'/''/g")
  sqlite3 "$NEW_DB" "INSERT OR IGNORE INTO contacts (name, phone, email, relationship, status, notes, last_contact, created_at, updated_at) VALUES ('$name', '$phone', '$email', '$rel', '$status', '$notes', '$last', '$created', '$updated');"
done

# Migrar tarefas
sqlite3 "$OLD_DB2" "SELECT project_id, title, description, status, priority, due_date, created_at, updated_at FROM tasks;" 2>/dev/null | while IFS='|' read pid title desc status priority due created updated; do
  desc=$(echo "$desc" | sed "s/'/''/g")
  sqlite3 "$NEW_DB" "INSERT OR IGNORE INTO tasks (project_id, title, description, status, priority, due_date, created_at, updated_at) VALUES ($pid, '$title', '$desc', '$status', '$priority', '$due', '$created', '$updated');"
done

# Migrar eventos
sqlite3 "$OLD_DB2" "SELECT title, description, event_date, event_time, location, status, google_event_id, created_at, updated_at FROM events;" 2>/dev/null | while IFS='|' read title desc date time location status gid created updated; do
  desc=$(echo "$desc" | sed "s/'/''/g")
  sqlite3 "$NEW_DB" "INSERT OR IGNORE INTO events (title, description, event_date, event_time, location, status, google_event_id, created_at, updated_at) VALUES ('$title', '$desc', '$date', '$time', '$location', '$status', '$gid', '$created', '$updated');"
done

echo "📊 Estatísticas do novo ATLAS.DB:"
echo "  - Projetos: $(sqlite3 $NEW_DB 'SELECT COUNT(*) FROM projects;')"
echo "  - Contatos: $(sqlite3 $NEW_DB 'SELECT COUNT(*) FROM contacts;')"
echo "  - Tarefas: $(sqlite3 $NEW_DB 'SELECT COUNT(*) FROM tasks;')"
echo "  - Eventos: $(sqlite3 $NEW_DB 'SELECT COUNT(*) FROM events;')"
echo "  - Referências de arquivos: $(sqlite3 $NEW_DB 'SELECT COUNT(*) FROM file_references;')"

# Criar symlink para compatibilidade (opcional)
# ln -sf "$NEW_DB" "$DB_DIR/projects.db"

echo "✅ Migração concluída! Novo banco: $NEW_DB"
echo "📁 Backups dos bancos antigos em: $DB_DIR/backup/"
