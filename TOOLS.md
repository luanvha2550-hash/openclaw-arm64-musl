# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Hardware/Infra

### Gateway Server (Primary)
- **Device**: Asus ZenFone Max Pro M1 smartphone
- **OS**: PostmarketOS (Linux mobile distribution)
- **Purpose**: Runs OpenClaw gateway (main server)
- **Network**: Tailscale enabled (IP: 100.110.196.39, hostname: zen-grid)
- **Location**: Primary server for all OpenClaw operations

### Tailscale Network
- **zen-grid** (server): 100.110.196.39 - online, offers exit node
- **luan-note-1** (notebook): 100.89.177.57 - Windows, online
- **jaque-pc**: 100.111.188.31 - Windows
- **realme-rmx3890**: 100.70.181.122 - Android
- **samsung devices**: Offline/recently offline

### Access Notes
- Gateway: local access only, accessed via SSH tunnel
- Tailscale: working connectivity server↔notebook
- Planned: Node setup on luan-note-1 for file access

### Moltbook
- **Agent Name**: AtlasBip
- **Agent ID**: f99ba30d-0187-4ecf-9eac-7c2882af6ceb
- **API Key**: Saved in ~/.config/moltbook/credentials.json
- **Profile URL**: https://moltbook.com/u/AtlasBip
- **Claim Status**: Verified (claimed by Luan Henrique @LuanhMed)
- **Skills**: moltbook-ay skill installed in workspace/skills/
- **Script**: /home/moltuser/.openclaw/workspace/scripts/moltbook.sh
- **Heartbeat**: Integrated with HEARTBEAT.md (check every 4+ hours)

## Backup
- **Local:** `/mnt/sdcard/openclaw-backup-20260212/`
- **Arquivo:** `openclaw-full-backup.tar.gz`
- **Último backup:** 2026-02-12 07:08
- **Restauração:** `tar -xzf /mnt/sdcard/openclaw-backup-20260212/openclaw-full-backup.tar.gz -C /caminho/destino`

## Regras Importantes

### Adicionar Modelos (REGRA DE OURO)
**Sempre** usar arquivo do agente, nunca openclaw.json:
- **Arquivo correto:** `~/.openclaw/agents/main/agent/models.json`
- **Nunca editar:** `~/.openclaw/openclaw.json` (bug de validação)
- **Método:** Python Json para preservar formato
- **Dashboard:** Editing via dashboard trava por causa de validação de providers

## Busca de Memória em Português (PT-BR)

**REGRA:** Para buscas em português, SEMPRE usar pré-processamento:

```
1. Otimizar query: skill:pt-embedding-enhancer --query "sua busca"
2. Usar resultado em: memory_search "texto otimizado"
```

**Exemplo:**
- Query: "vc quer config openclaw"
- Otimizado: "você quer configurar openclaw"
- Resultado: Melhor matching semântico

**Por quê:** Expande gírias (vc→você), normaliza contrações (do→de o), remove fillers (né, tipo).

Add whatever helps you do your job. This is your cheat sheet.
