# cliproxy — Implementation Plan

> Adapted from Theo (theo4gg)'s guide: *"How I manage 7 Claude and 3 Codex accounts across 12+ computers"*  
> Full credit to Theo. See [`CREDITS.md`](CREDITS.md).  
> ⚠️ Read [`NOTICE.md`](NOTICE.md) before deploying.

## Overview

Single home Ubuntu server runs **CLIProxyAPI in Docker** as a central auth proxy for Claude and Codex accounts. All client machines (laptops, servers, cloud boxes) point at the hub over **Cloudflare Tunnel** (Theo uses Tailscale; this repo adapts for Cloudflare Tunnel). Tools served through the hub: **Zed, OpenCode, Claude Code, Codex CLIs**.

Auth sign-ins happen on the hub only. **You** perform OAuth/browser logins yourself. This agent never touches auth files, access keys, or the management key.

---

## Repository Structure

```
clipproxy/
├── .env.example              # Copy to .env, set your secrets
├── .gitignore                # Ignores .env, data/, backups/, logs
├── LICENSE.md                # MIT License
├── Makefile                  # Convenience targets
├── NOTICE.md                 # ⚠️ Legal disclaimer — READ THIS FIRST
├── CREDITS.md                # Attribution to Theo (theo4gg) and third parties
├── GUIDE.md                  # Full setup guide (adapted from Theo's guide)
├── PLAN.md                   # This file — execution checklist
├── README.md                 # Overview + client configs
├── SECURITY.md               # Security policy & secrets handling
├── CONTRIBUTING.md           # Repo conventions
├── CHANGELOG.md              # Version history
├── config.yaml               # Simple root-level config (<CHANGE_ME> placeholders)
├── docker-compose.yml        # Simple root-level compose
├── config/
│   └── config.yaml.example   # CLIProxyAPI v8 config (env var interpolation)
├── docker/
│   └── docker-compose.yml    # Compose with optional cloudflared tunnel profile
├── cloudflare/
│   └── tunnel-config.yml.example
├── clients/
│   ├── claude-code/settings.json.example
│   ├── codex/config.toml.example
│   ├── opencode/.env.example
│   └── zed/settings.json.example
├── scripts/
│   ├── setup-hub.sh          # Full Ubuntu hub provisioning
│   ├── health-check.sh       # Verify /v1/models responds
│   ├── backup.sh             # Tar the data/ auth state
│   └── signin-codex.sh       # Docker-based Codex device login
└── systemd/
    └── cliproxyapi.service   # Systemd unit template
```

---

## Prerequisites on the Hub (Ubuntu Server)

Run these **before** deploying:

```bash
# 1. OS check
uname -a

# 2. Datacenter check — must NOT be a cloud host
curl -s https://ipinfo.io/org
# Stop if org is AWS, Hetzner, DigitalOcean, OVH, Google, Microsoft, Linode, Vultr, etc.

# 3. Port 8317 must be free
ss -ltn | grep 8317
# Should return nothing

# 4. Docker must be installed
docker --version
docker compose version

# 5. Prevent sleep
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

Or run the automated setup script:

```bash
make setup   # runs scripts/setup-hub.sh
```

---

## Step 1: Prepare Config on the Hub

```bash
mkdir -p ~/cliproxyapi/{config,data}
cd ~/cliproxyapi
```

Copy these files from the repo:

- `config/config.yaml.example` → `config/config.yaml`
- `docker/docker-compose.yml` → `docker-compose.yml`
- `.env.example` → `.env`

Edit **yourself** (never commit real values):

### `.env`

```bash
CLIPROXY_ACCESS_KEY=<generate-strong-random-string>   # e.g. openssl rand -hex 32
CLIPROXY_MANAGEMENT_KEY=<generate-strong-random-string>
TUNNEL_URL=https://<your-tunnel-url>                  # set after tunnel is created
DATA_DIR=./data
```

### `config/config.yaml`

```yaml
config-version: 8
server:
  host: "0.0.0.0"
  port: 8317
  trusted-proxies: ["127.0.0.1", "::1"]
management:
  allow-remote: true
  secret-key: "${CLIPROXY_MANAGEMENT_KEY}"
access:
  api-keys:
    - "${CLIPROXY_ACCESS_KEY}"
routing:
  strategy: "round-robin"
  session-affinity: true
  session-affinity-ttl: "1h"
  retry:
    request-retry: 3
    max-retry-interval: 30
```

> **Never print, paste, or commit the real access key or management key.** See [`NOTICE.md`](NOTICE.md) and [`SECURITY.md`](SECURITY.md).

---

## Step 2: Deploy Docker Container

```bash
cd ~/cliproxyapi
make up
# or: docker compose up -d
```

Verify:

```bash
docker ps
# cliproxyapi should be Up
make health
```

---

## Step 3: Cloudflare Tunnel

Expose port 8317 via Cloudflare Tunnel pointed at `http://127.0.0.1:8317`.

### Option A: Quick tunnel (ephemeral URL)

```bash
cloudflared tunnel --url http://localhost:8317
```

### Option B: Named tunnel (persistent URL)

```bash
cloudflared tunnel create cliproxy
cloudflared tunnel route dns cliproxy cliproxy.yourdomain.com
# Then use docker/docker-compose.yml with the tunnel profile:
docker compose --profile tunnel up -d
```

Your hub endpoint: `https://<your-tunnel-url>`

---

## Step 4: Client Configurations (Second Config Dir Approach)

This keeps normal Claude Code / Codex installs untouched. Opt-in per machine and per tool.

### Claude Code — `~/.claude-hub/settings.json`

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://<your-tunnel-url>",
    "ANTHROPIC_AUTH_TOKEN": "<your-access-key>"
  }
}
```

```bash
CLAUDE_CONFIG_DIR=~/.claude-hub claude
```

### Codex — `~/.codex-hub/config.toml`

```toml
model_provider = "cliproxy"

[model_providers.cliproxy]
name = "CLIProxyAPI"
base_url = "https://<your-tunnel-url>/v1"
wire_api = "responses"
requires_openai_auth = false
supports_websockets = true
experimental_bearer_token = "<your-access-key>"
```

```bash
CODEX_HOME=~/.codex-hub codex
```

### OpenCode

```bash
export ANTHROPIC_BASE_URL="https://<your-tunnel-url>"
export ANTHROPIC_AUTH_TOKEN="<your-access-key>"
```

### Zed

Add a custom Anthropic provider in Zed settings:
- Base URL: `https://<your-tunnel-url>`
- API Key: `<your-access-key>`

See [`clients/`](clients/) for example files.

---

## Step 5: Sign-Ins (You Perform These on the Hub)

Run from `~/cliproxyapi` on the server:

```bash
make signin-codex    # Codex device login
make signin-claude   # Claude login (interactive)
```

Or manually:

```bash
# Codex (device code — easiest headless)
docker run --rm -it -v "$HOME/cliproxyapi/data:/app/data" \
  eceasy/cli-proxy-api:latest -codex-device-login

# Claude
docker run --rm -it -v "$HOME/cliproxyapi/data:/app/data" \
  eceasy/cli-proxy-api:latest -claude-login
```

**Headless Claude login:** OAuth callback lands on port 54545. Tunnel from your laptop:

```bash
ssh -L 54545:localhost:54545 <hub>
```

Then open the URL the command prints. Add `-no-browser` to print the URL instead of launching a browser. Codex's browser callback is port 1455 — same tunnel trick.

Repeat per account. Then confirm in the management panel:

```
https://<your-tunnel-url>/management.html
```

---

## Step 6: Verify From Another Machine

```bash
make health
# or manually:
curl -s https://<your-tunnel-url>/v1/models \
  -H "Authorization: Bearer <your-access-key>" | head -c 300
```

Should return a JSON model list.

---

## Theo's Changes (From His Guide)

| Change | Status in This Repo |
|--------|---------------------|
| Session affinity (`session-affinity: true`) | ✅ Enabled in config |
| Soonest-reset-first routing | ❌ Not in upstream — task for you |
| Codex over websockets (`supports_websockets: true`) | ✅ Enabled in Codex client config |

See [`GUIDE.md`](GUIDE.md) for Theo's full original guidance.

---

## Risk Acknowledgement (Theo's Two Hard Rules)

1. **Do not serve other people's traffic with your subscriptions.**
2. **Only use Claude models through Claude Code over the proxy.**

See [`NOTICE.md`](NOTICE.md) for the full legal disclaimer.

---

## Maintenance

- Auth state lives in `~/cliproxyapi/data/` on the hub. Back it up regularly:
  ```bash
  make backup
  ```
- If Codex returns `token_invalidated` (401), rerun device login on the hub.
- If an account needs benched, set `"disabled": true` in its auth JSON (no restart needed).
- If only one account is enabled per provider, a limit hit has nowhere to go. Add more accounts if possible.
