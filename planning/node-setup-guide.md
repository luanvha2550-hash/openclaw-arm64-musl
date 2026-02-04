# Node Setup Guide - Windows Notebook (luan-note-1)

**Goal:** Install OpenClaw as a node on Windows notebook to enable file access and remote execution via Tailscale.

**Prerequisites:**
- Windows notebook (luan-note-1) with Tailscale installed and connected (IP: 100.89.177.57)
- Gateway server (zen-grid) running OpenClaw (IP: 100.110.196.39, port: 18789)
- Gateway token: `736cb7b82353214c9bc2f8476236be79eb6f68b322fb07db`
- Admin/User access to install software

---

## Step 1: Install Node.js 22+ and Git

### Option A: Using Winget (recommended)
Open PowerShell as Administrator:
```powershell
# Install Node.js
winget install OpenJS.NodeJS.LTS

# Install Git
winget install Git.Git

# Verify installations
node --version  # Should show v22.x or higher
npm --version   # Should show 10.x or higher
git --version
```

### Option B: Manual download
- Node.js: https://nodejs.org/ (Download LTS version)
- Git: https://git-scm.com/download/win

---

## Step 2: Install OpenClaw

Open PowerShell (regular user):

```powershell
# Install via PowerShell installer (recommended)
iwr -useb https://openclaw.ai/install.ps1 | iex
```

**If installer asks for choices:**
- Install method: `npm` (default)
- Skip onboarding: Choose `--no-onboard` (we'll configure manually)

**Alternative if installer fails:**
```powershell
# Manual npm install
npm install -g openclaw@latest

# Verify installation
openclaw --version
```

**Troubleshooting PATH:**
If `openclaw` not found, add npm global bin to PATH:
```powershell
# Get npm global prefix
npm config get prefix

# Typically: C:\Users\<YourUser>\AppData\Roaming\npm
# Add this directory to System PATH environment variable
```

---

## Step 3: Configure Node Host

Create a directory for node configuration and run:

```powershell
# Set gateway token as environment variable
$env:OPENCLAW_GATEWAY_TOKEN="736cb7b82353214c9bc2f8476236be79eb6f68b322fb07db"

# Run node host (foreground, will show logs)
openclaw node run --host 100.110.196.39 --port 18789 --display-name "luan-note-1-windows"
```

**Expected output:**
- Connection attempt to gateway
- Node ID generated
- Waiting for pairing approval

**Keep this PowerShell window open** - it's the node host process.

---

## Step 4: Approve Pairing on Gateway

On the gateway server (zen-grid), I will:
1. Check pending pairing requests: `openclaw nodes pending`
2. Approve your node: `openclaw nodes approve <requestId>`
3. Verify connection: `openclaw nodes status`

**I'll notify you when approved.** Once approved, the node host will show "paired" status.

---

## Step 5: Test Connection

After pairing, test basic functionality:

```powershell
# From notebook (different PowerShell window)
openclaw nodes status

# Or from gateway (I'll run):
openclaw nodes describe --node luan-note-1-windows
```

---

## Step 6: Configure File Access (Optional)

Once node is paired, we can configure file sharing:

### Option A: Direct file access via exec
I can run commands on your notebook:
```bash
# From gateway session
exec host=node node=luan-note-1-windows command="dir C:\Users\<YourUser>\Documents"
```

### Option B: Shared directory via Tailscale
Set up a shared folder that both nodes can access.

---

## Troubleshooting

### Connection refused
If `openclaw node run` fails to connect:
1. **Verify Tailscale connectivity:**
   ```powershell
   ping 100.110.196.39
   ```

2. **Check gateway port accessibility:**
   ```powershell
   Test-NetConnection -ComputerName 100.110.196.39 -Port 18789
   ```

3. **Gateway may be bound to localhost only:**
   - On gateway, check config: `gateway.mode` should allow external connections
   - May need SSH tunnel (see below)

### SSH Tunnel Alternative
If gateway only accepts local connections:

**On notebook (PowerShell):**
```powershell
# Install OpenSSH Client if not present
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Create tunnel (replace USER with your server username)
ssh -N -L 18790:127.0.0.1:18789 moltuser@100.110.196.39
```

**Then connect node to local tunnel:**
```powershell
openclaw node run --host 127.0.0.1 --port 18790 --display-name "luan-note-1-windows"
```

### Permission issues
Run PowerShell as Administrator if install fails.

---

## Next Steps After Setup

1. **Test file access:** I'll list directories on your notebook
2. **Configure automation:** Set up sync of study documents
3. **Integrate with study system:** Use node for Anki sync, file backups
4. **Optional:** Set up node as service (run automatically on startup)

---

## Security Notes

- Node host runs with your user permissions
- I can only execute commands you approve via exec approvals
- Tailscale encrypts all traffic between devices
- Gateway token is sensitive - don't share publicly

---

## Quick Reference Commands

**Notebook commands:**
```powershell
# Start node host
openclaw node run --host 100.110.196.39 --port 18789 --display-name "luan-note-1-windows"

# Install as Windows service (after testing)
openclaw node install --host 100.110.196.39 --port 18789 --display-name "luan-note-1-windows"
openclaw node restart

# Check node status
openclaw nodes status
```

**Gateway commands (I'll run):**
```bash
# List pending nodes
openclaw nodes pending

# Approve node
openclaw nodes approve <requestId>

# List paired nodes
openclaw nodes status

# Test exec on node
exec host=node node=luan-note-1-windows command="whoami"
```

---

**When you're ready:** Let me know and we can start with Step 1. Estimated time: 15-30 minutes for full setup.

**Note:** If you prefer, we can do this in a video call/screenshare for real-time assistance.