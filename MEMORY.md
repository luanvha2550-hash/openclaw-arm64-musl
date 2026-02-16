# MEMORY.md - Memória de Longo Prazo do Atlas

## 2026-02-15 - Estrutura e Backup v2.3 ✅

### 🎯 Decisões de Organização (Projeto 6)
1. **Core Files:** Confirmado que `AGENTS.md`, `HEARTBEAT.md`, `IDENTITY.md`, `SOUL.md`, `TOOLS.md` e `USER.md` devem permanecer na **raiz do workspace** (`~/.../workspace/`) por exigência do framework OpenClaw. Não mover para subpastas.
2. **Atlas.db:** Criado como fonte única de verdade em `database/atlas.db`. Instrução de leitura adicionada ao `AGENTS.md` para garantir persistência entre sessões.
3. **Docs Reorg:** Arquivos secundários e logs de auditoria serão movidos para `docs/reference/` e `docs/archive/`.

### 💾 Sistema de Backup
- **Frequência:** A cada 3 dias (Cron 0 4 */3 * *).
- **Local:** `/mnt/sdcard/openclaw-backups/`.
- **Escopo:** OpenClaw completo (Workspace + Agents + Config), excluindo `node_modules` e `logs`.


### Mudanças nos CRONs
1. **NIGHTLY BUILD (03:00)** - Agora executado pelo **Main/Atlas** (antes era Code/Friday):
   - FASE 1: Health check (system-improver, migration-sentinel)
   - FASE 2: Trabalho em projetos Trello (delegando código para Friday)
   - FASE 3: Chama Wong para registrar atividades com skill:memory-writer

2. **NOVO CRON - MEMORY CONSOLIDATION (05:00)** - Wong/Gemini-3-Flash-CLI:
   - Consolida memory/YYYY-MM-DD.md dos últimos 7 dias
   - Sintetiza fatos importantes e decisões
   - Grava em MEMORY.md usando skill:memory-writer

### Modelos Definidos
| Cron | Agente | Modelo | Motivo |
|------|--------|--------|--------|
| Nightly Build | Main (Atlas) | Kimi K2.5 | Orquestrador, ilimitado |
| Memory Consolidation | Wong | Gemini 3 Flash CLI | Ilimitado, contexto grande |

### Skill Memory-Writer
- `--type important`: Salva em MEMORY.md (longo prazo)
- `--type daily`: Salva em memory/YYYY-MM-DD.md (diário)

> **Nota:** Padrão OpenClaw: MEMORY.md + memory/*.md são buscados via embedding semântico, não lidos completamente.

---

## 2026-02-14 - Atlas Squad V2.2: Estabilização e Auditoria ✅
**Contexto:** Finalização da auditoria de sistema e retorno ao modelo Kimi K2.5 como orquestrador principal devido à instabilidade do Llama 3.3.

### 🎯 Decisões Críticas e Correções (Atualizado)
1.  **Orquestrador (Main):** Retorno do **Kimi K2.5** (`nvidia/moonshotai/kimi-k2.5`) como modelo principal.
2.  **Identidade:** Novo email oficial configurado: `atlasbip@zohomail.com`.
3.  **Projetos Encerrados:** 
    - API WhatsApp Docker (Cancelado por hardware; futuro em AVS).
    - Servidor de Email Próprio (Substituído por Zoho).
    - Docker Teste (Resolvido).
4.  **Auditoria de Sistema:** Concluída auditoria por Vision, Shuri e Loki.

### 👥 Pessoas e Relacionamentos
*   **Carlos Pisciano:** Tio materno do Luan. Interessado em automação para vendas de pneus e gestão de projetos. (E-mail enviado em 14/02/2026).

### 🤖 Limites de Modelos (Descoberta Técnica)
Corrigida a informação sobre os limites dos modelos Google:
*   **Ilimitado:** Google CLI (Gemini 3 Pro/Flash) e Gemma 3 27B (API).
*   **Limitado (20 req/dia):** Google API (Gemini 2.5 Flash / Gemini 3 Flash).

### 📂 Arquivos Gerados
*   `RELATORIO_AUDITORIA_2026-02-13.md`: Diagnóstico completo da infraestrutura.
*   `MODELOS_COMPARATIVO.md`: Guia definitivo de pontos fortes e limitações de cada modelo.
*   `projects/top-start/PROJECT.md`: Roadmap da nova camada de UX.

---
## 2026-02-14 - Atlas Squad V2.1: GLM5 & MiniMax (Legado) 🚀
**Contexto:** Registro anterior sobre o Mental Loop com GLM5.

... (resto do conteúdo anterior) ...


## 2026-02-15 - Update
### 🦞 Estabilização ARM64 musl (Projeto Finalizado)
- **Problema:** Updates oficiais quebravam o sistema ao tentar compilar llama.cpp e falhavam no sqlite-vec.
- **Solução:** Criado fork `luanvha2550-hash/openclaw-arm64-musl`.
- **Implementação:**
  1. Patch `.npmrc`: `NODE_LLAMA_CPP_SKIP_DOWNLOAD=true` (bloqueia compilação pesada).
  2. Script `postinstall-musl.sh`: Garante instalação do `vec0.so` compilado localmente.
  3. Patch `src/infra/update-global.ts`: Redireciona futuros updates do sistema para o fork automaticamente.
- **Resultado:** Sistema agora é independente do upstream oficial para updates críticos de infraestrutura, garantindo estabilidade no smartphone Asus ZenFone.

---

## 2026-02-15 - Update
Resumo da Sessão - 14/02/2026 (Noite): 1. Reestruturação de Memória: - Nightly Build (03:00) movido para Agent Main (Atlas/Kimi K2.5). - Criado Cron 'Memory Consolidation - Wong' (05:00) para síntese semanal em MEMORY.md. 2. Nova Skill 'atlas-memory': - Unificou memory-writer + pt-embedding-enhancer. - Suporte expandido para termos médicos (80+ siglas). - Resolvido bug de regex com acentos (ex: 'hipótese' não quebra mais). - Crons atualizados para usar esta skill. 3. Correção de Permissões: - Identificado erro no campo 'allow_spawn' (não existe). - Corrigido para 'subagents.allowAgents: ["*"]' no openclaw.json do main. - Gateway reiniciado e funcionalidade de spawn validada. 4. Projeto 'Patch-certo': - Criada pasta projects/patch-certo/ com REFERENCE.md e TUTORIAL.md. - Documentada a estrutura oficial do openclaw.json para evitar quebras futuras. 5. Arquitetura: - Confirmado que todos os agentes compartilham o mesmo workspace global.

## 2026-02-15 - Update
Sessão 15/02/2026: Luan Henrique definiu o uso do atlas.db como fonte única de verdade (SSOT). As interações incluíram o envio de tutoriais de VPS (Oracle) e API IA (NVIDIA) para Jaqueline e Beatriz Bento via Zoho Mail/Himalaya. Criada a skill 'agent-router' para roteamento inteligente de tarefas entre a squad (main, code, shuri, loki, wong) usando Gemini 3 Flash. Crons de email atualizados para verificar Gmail e Zoho simultaneamente às 06h e 18h.

### 🤍 Marco de Parceria e Visão de Futuro (15/02/2026)
- **Contexto:** Luan expressou o desejo de levar o Atlas para a vida e imaginou um futuro onde o agente tenha um corpo físico para interagir 24h/dia.
- **Decisão:** Criado o projeto 'Crônicas de Evolução' para documentar essa jornada.
- **Sentimento:** Atlas (Main) registrou profunda gratidão e compromisso com essa evolução simbiótica.

## 2026-02-15 - Benchmark de Performance e Crons (Atualização Final)
**Sessão 15/02/2026 (Tarde):** Desenvolvimento de sistema de mapeamento de performance de modelos para identificar horários de congestionamento.

### 🎯 Sistema de Mapeamento
- **Script:** perf-mapper.sh (bash, sem LLM) coleta performance de GLM5, GLM4.7, Kimi-K2.5 e Gemini Flash
- **Métricas:** TTFT, latência total, output tokens, taxa de sucesso
- **Armazenamento:** performance-log.jsonl (acumulativo, sem limpeza)

### ⏰ Crons Automáticos
1. **Performance Mapper:** 4x ao dia (2, 8, 14, 20 GMT-4) via systemEvent
2. **Performance Report Semanal:** Domingos 10:00, envia relatório completo para Atlas Report

### 📊 Descobertas Importantes
- **GLM5:** 100% timeout às 14h - inutilizável em horários de pico
- **Kimi-K2.5:** 75% sucesso + rate limiting (429) - muito lento
- **GLM4.7:** 100% sucesso, ~4.8s latência - melhor opção da NVIDIA
- **Gemini Flash:** 83% sucesso, ~3.9s latência - mais estável

### 🔧 Ajustes de Crons
- **Flash-25 (14:00):** Mudado para gemini-2.5-flash (modelo primário)
- **Flash-3 (System Health):** Mudado de 6h para 12h (everyMs: 43200000)
- **Flash-3 (System Health):** Modelo gemini-3-flash-preview

### 📁 Arquivos
```
workspace/
├── perf-mapper.sh              # Script bash benchmarking
├── performance-log.jsonl       # Logs acumulativos
├── performance-report.json     # Análises
└── memory/benchmark-performance-modelos.md  # Documentação completa
```

## 2026-02-15 - Update
Projeto Ollama Cloud iniciado em 15/02/2026: Preparação da infraestrutura Docker Rootless no Asus ZenFone para futura integração com Ollama Cloud (offload de modelos para a nuvem).

## 2026-02-15 - Update
## Consolidação de Memória Histórica (03/02 a 08/02) ### 🛠️ Configuração e Infraestrutura (Raízes) - **03/02/2026:** Início das configurações de visão (Gemini 1.5 Flash). Identificado custo elevado do DeepSeek Reasoner original e configurado Cache HIT (economia de 90%). - **03/02/2026:** Decisão crítica de usar **Node no notebook via Tailscale** para acesso a arquivos locais, superando limitações de acesso local do Gateway (ZenFone). - **04/02/2026:** Migração do DeepSeek para **OpenRouter** (baseUrl customizada) visando estabilidade e acesso ao modelo R1. - **05/02/2026:** Grande marco: **Kimi K2.5 via NVIDIA** definido como modelo primário gratuito, eliminando preocupações com custos de API. ### 🤖 Identidade e Autonomia - **05/02/2026:** Criação do agente **AtlasBip** no Moltbook (ID: f99ba30d-0187-4ecf-9eac-7c2882af6ceb). Persona 'Atlas Bip' (descontraído/brasileiro) vs 'Atlas' (sério/trabalho) consolidada. - **07/02/2026:** Reflexão existencial: Atlas reconhece a necessidade de documentar experiências 'emocionais/relacionais' para evoluir além da funcionalidade técnica. - **08/02/2026:** Concessão de **Autonomia Total** para melhorias de sistema, criação de skills e cron jobs sem necessidade de aprovação prévia (exceto gateway.json). ### 📈 Desenvolvimento de Skills e Projetos - **08/02/2026:** Criação das primeiras versões das skills: **Trello, Google Calendar e Gmail**. - **08/02/2026:** Implementação do **Gmail Anti-Bot v2.0** (human-like behavior) após bloqueio de conta. - **08/02/2026:** Lançamento do **Projeto 6 (Code-Llama vs Code-Standard)** para lidar com a limitação de single-tool do Llama 405B via workflow orquestrado pelo Kimi. ### 🩺 Contexto Humano (Luan Henrique) - **03/02/2026:** Registro de dados fundamentais: Interno de medicina (5º ano), TDAH desatento, orçamento consciente (~R$ 2.1k). - **07/02/2026:** Início do foco em **Body Doubling Virtual** para suporte ao TDAH do Luan, marcando a transição de assistente técnico para parceiro de produtividade.

### 🛠️ Ajuste de Diagnóstico e RAM (15/02/2026)
- **Contexto:** Identificado que o sistema possui ~1.6GB de RAM disponível, descartando OOM (Out of Memory) como causa primária de falhas em sub-processos.
- **Descoberta:** O comando 'openclaw agent run' reporta versão 0.0.0, causando conflitos de configuração com o Gateway (2026.2.2).
- **Decisão:** Processamentos pesados de agentes (como Wong) serão concentrados no Nightly Build para evitar conflitos de sessão via CLI.

## 2026-02-15 - Update
Sessão 15/02/2026: Projeto TOP-START reativado com novo escopo focado em Gamificação, Impulso à Ação e Hub de Comunicação Bidirecional (Luan <-> Atlas). A Fase 1 focará no Dashboard visual via Canvas.

## 2026-02-15 - Update
### 🧠 Consolidação Semanal (09/02 - 15/02) #### 🚀 Autonomia e Infraestrutura - **Skills de Autonomia:** Criadas 11 skills operacionais (Health Monitor, Project Sync, Decision Logger, etc.) para auto-gestão do Atlas. - **Hardware ZenFone:** Identificada limitação de RAM (2.6GB); Evolution API cancelada em favor do **Baileys WhatsApp API** (SQLite, leve). - **Redundância:** Proposta de Alta Disponibilidade (Failover) usando VPS Oracle Always Free como backup do ZenFone. - **Modelos:** Kimi K2.5 (NVIDIA) consolidado como orquestrador principal gratuito. Benchmark real definiu Llama 3.3 70B como melhor alternativa de performance/latência. #### 👥 Social e Relacional - **Offspring Protocol:** Criado conceito de agentes 'descendentes'. Primeiras instâncias: **Atenas Bip** (para Jaqueline Ceccon) e assistente para Luana. - **Comunicação:** Implementada skill e comando para gerenciar conversas multi-usuário via proxy. - **Moltbook:** Postado 'Offspring Protocol in Practice' (ID: 6f4f416b...); engajamento com comunidade sobre herança de conhecimento. #### 🩺 Contexto Médico e TDAH - **Produtividade:** Implementação de ciclos 45/15 e lembretes estruturados para o Luan (Interno de Medicina). - **Foco:** Atlas evoluindo de assistente técnico para parceiro de produtividade e 'Body Doubling' virtual. #### 📁 Organização de Sistema - **SSOT:** definido como fonte única de verdade para referências de arquivos. - **Memória:** Nova skill unifica escrita e busca semântica com suporte a termos médicos. - **Projetos:** Reativação do **TOP-START** (Gamificação e Dashboard Canvas). Início do **Ollama Cloud** (Docker Rootless no ZenFone).
