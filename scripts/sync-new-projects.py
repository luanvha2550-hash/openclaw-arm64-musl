#!/usr/bin/env python3
"""
Adiciona os novos projetos Mini LLM Local e TDAO ao atlas.db
e também ao PROJECTS.md para sincronização
"""

import sqlite3
from datetime import datetime

DB_PATH = "/home/moltuser/.openclaw/workspace/projects/database/projects.db"
PROJECTS_MD = "/home/moltuser/.openclaw/workspace/projects/PROJECTS.md"

def add_project(name, description, status, priority):
    """Adiciona um projeto ao database"""
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO projects (name, description, status, priority, created_at, updated_at)
        VALUES (?, ?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
    ''', (name, description, status, priority))

    project_id = cursor.lastrowid
    conn.commit()
    conn.close()
    return project_id

def sync_to_trello_projects_md():
    """Atualiza PROJECTS.md com os novos projetos"""
    # Ler atual
    with open(PROJECTS_MD, 'r') as f:
        content = f.read()

    # Verificar se já sincronizou
    if "Mini LLM Local" in content and "Task Detection & Automation" in content:
        print("✓ PROJECTS.md já sincronizado")
        return

    # Adicionar entry
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M')
    new_entries = f"""

## {timestamp} - Projetos Novos Sincronizados

### Mini LLM Local
*Status:* Planejamento
*Prioridade:* 8
*Objetivo:* Deploy de Ollama em multi-device (ZenFone, Notebook, VPS Oracle) para economia 90% de APIs

### Task Detection & Automation Optimization (TDAO)
*Status:* Começando
*Prioridade:* 7
*Objetivo:* Identificar tarefas frequentes executadas por LLM para otimizar/automatizar sem LLM

---

"""

    with open(PROJECTS_MD, 'a') as f:
        f.write(new_entries)

    print(f"✓ PROJECTS.md atualizado")

def main():
    print("🔄 Sincronizando novos projetos...")

    # Adicionar Mini LLM Local
    print("\n📝 Adicionando Mini LLM Local...")
    project_id_1 = add_project(
        name="🤖 Mini LLM Local",
        description="Deploy de Ollama em 3 dispositivos (ZenFone: TinyLigma, Notebook: Qwen2.5, VPS Oracle: Llama-3.1-8B) para economia 90% de requisições API. Arquitetura 2-Tier: LLM Local processa → Resumo condensado → Gemini só se necessário.",
        status="planned",
        priority=8
    )
    print(f"✓ Criado projeto Mini LLM Local (ID: {project_id_1})")

    # Adicionar TDAO
    print("\n📝 Adicionando TDAO...")
    project_id_2 = add_project(
        name="🔍 Task Detection & Automation Optimization (TDAO)",
        description="Identificar tarefas frequentes executadas por LLM que podem ser: (1) Automatizadas com scripts/bash sem LLM, (2) Delegadas para LLM local via Ollama, (3) Otimizadas para modelos mais leves. Three-Tier Architecture com Layer 1 (scripts), Layer 2 (LLM local), Layer 3 (Cloud LLM).",
        status="in_progress",
        priority=7
    )
    print(f"✓ Criado projeto TDAO (ID: {project_id_2})")

    # Sincronizar para PROJECTS.md
    print("\n📄 Atualizando PROJECTS.md...")
    sync_to_trello_projects_md()

    print(f"\n✅ Sincronização completa!")
    print(f"   - 2 projetos adicionados ao atlas.db")
    print(f"   - PROJECTS.md atualizado")
    print(f"   - Total: {project_id_2} projetos no database")

if __name__ == "__main__":
    main()
