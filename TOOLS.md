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

Add whatever helps you do your job. This is your cheat sheet.
