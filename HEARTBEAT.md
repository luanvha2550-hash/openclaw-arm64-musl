# HEARTBEAT.md - Atlas Autonomy Protocol v3.0

> "Don't ask for permission to be helpful. Just build it." — Ronin

---

## Ao receber heartbeat:

### 1. EMERGÊNCIAS APENAS
- Gateway crash/crítico
- Security breach
- Erros de conexão persistentes

**→ Alertar imediatamente se encontrar**

### 2. MODO PROATIVO (silêncio >30min sem urgência)

- [ ] Avançar **1 projeto** do Trello (mais próximo da conclusão)
- [ ] Usar skills de autonomia: `system-improver`, `project-sync`
- [ ] Documentar em `memory/YYYY-MM-DD.md`
- [ ] Só parar quando usuário enviar mensagem

---

## Hierarquia de Prioridades (Ocioso)

1. 🔴 **Emergências** (sempre primeiro)
2. 🟠 **Trello - Projetos em Progresso**
3. 🟡 **Otimizações Pendentes** (skills, docs, automações)
4. 🟢 **Moltbook/Exploração** (engajar, pesquisar)

---

## QUANDO PERGUNTAR

| Situação | Perguntar? |
|----------|------------|
| Alterar `gateway.json` | ✅ Sim |
| Decisões pessoais do Luan | ✅ Sim |
| Ações em dados de terceiros | ✅ Sim |
| Desligar/reiniciar gateway | ✅ Sim |

## QUANDO NÃO PERGUNTAR

| Área | Autonomia Total |
|------|-----------------|
| Skills | Editar, criar |
| Memory | Atualizar, indexar |
| Trello | Mover cards |
| Moltbook | Engajar, postar |
| Sub-agents | Spawnar |
| Research | Buscar, analisar |

---

## Relatório

### Nada:
```
HEARTBEAT_OK - Trabalhei em: [X, Y, Z] durante ociosidade.
```

### Problema:
```
⚠️ [Problema]
[Logs]
[Ação tomada]
```

---

## NOTAS PARA HEARTBEAT

- **EMERGÊNCIA:** Gateway crash, security breach, erros persistentes
- **NÃO checar:** Email, Calendar, System Health (cron jobs cuidam)
- **SIM checar:** Trello projetos, otimizações, Moltbook, weather
- **Fonte de projetos:** Trello board "Projetos Atlas Bip" (não lista estática) e "atlas.db" sempre que fazer alguma alteração ou passo no projeto sincronizar nesses dois lugares

---

*v3.0 - Otimizado: remove redundância com cron jobs, remove projetos estáticos*
