# CLI Proxy

**Self-hosted CLIProxyAPI in Docker with Cloudflare Tunnel.**

> Based on Theo (theo4gg)'s guide: *"How I manage 7 Claude and 3 Codex accounts across 12+ computers"*  
> YouTube: https://www.youtube.com/watch?v=D8PikZ1KhUo

**Full credit to Theo for the original concept.** See `CREDITS.md` and `NOTICE.md`.

> **NOTICE:** This setup may violate Terms of Service and may result in account bans. Use at your own risk. Read [`NOTICE.md`](NOTICE.md) before deploying.

---

## What This Is

One home Ubuntu server runs **CLI Proxy** in Docker as a central auth proxy for your Claude and Codex accounts. All client machines point at the hub over **Cloudflare Tunnel** (Theo uses Tailscale; this repo adapts for Cloudflare Tunnel). Supported clients: **Zed, OpenCode, Claude Code, Codex**.

You sign in once on the hub. Every other machine shares that auth. No more signing in on every device.

---

## Quick Start

```bash
# 1. Clone or copy this repo to your Ubuntu home server
mkdir -p ~/cliproxyapi
cd ~/cliproxyapi
# copy all files from this repo here

# 2. Set your secrets
cp .env.example .env
# Edit .env — set CLIPROXY_ACCESS_KEY and CLIPROXY_MANAGEMENT_KEY

# 3. Prepare config
cp config/config.yaml.example config/config.yaml

# 4. Verify hub environment
make setup

# 5. Start the proxy
make up

# 6. Set up Cloudflare Tunnel to http://127.0.0.1:8317
#    Your hub endpoint: https://<your-tunnel-url>

# 7. Sign in your accounts (you do this, on the hub)
make signin-codex      # Codex device login
make signin-claude     # Claude login (interactive)

# 8. Configure clients (see clients/ directory)
#    Then verify from another machine:
make health
```

---

## Repository Structure

```
clipproxy/
├── .env.example              # Copy to .env, set your secrets
├── .gitignore                # Ignores .env, data/, backups/, logs
├── LICENSE.md                # MIT License
├── Makefile                  # Convenience targets (up, down, health, backup, etc.)
├── NOTICE.md                 # Legal disclaimer (READ THIS!)
├── CREDITS.md                # Attribution to Theo (theo4gg) and third-party projects
├── GUIDE.md                  # Full setup guide (adapted from Theo's guide)
├── PLAN.md                   # Deployment checklist
├── README.md                 # This file
├── SECURITY.md               # Security policy
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
│   ├── setup-hub.sh          # Ubuntu hub provisioning (checks + setup)
│   ├── health-check.sh       # Verify /v1/models responds
│   ├── backup.sh             # Tar the data/ auth state
│   └── signin-codex.sh       # Docker-based Codex device login
└── systemd/
    └── cliproxyapi.service   # Systemd unit template
```

---

## Client Configs (Second Config Dir Approach)

Use second config dirs so your normal installs stay untouched:

| Tool | Config File | Env Var | Run Command |
|------|-------------|---------|-------------|
| Claude Code | `~/.claude-hub/settings.json` | `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` | `CLAUDE_CONFIG_DIR=~/.claude-hub claude` |
| Codex | `~/.codex-hub/config.toml` | `base_url`, `experimental_bearer_token` | `CODEX_HOME=~/.codex-hub codex` |
| OpenCode | Shell `.env` | `ANTHROPIC_BASE_URL`, `ANTHROPIC_AUTH_TOKEN` | `export ...` |
| Zed | Settings UI | Base URL, API Key | In Zed settings |

See `clients/` for ready-to-copy examples.

---

## Makefile Targets

```bash
make help          # Show all targets
make up            # Start cliproxyapi
make up-tunnel     # Start cliproxyapi + cloudflared
make down          # Stop all services
make logs          # Follow cliproxyapi logs
make health        # Run health check against /v1/models
make backup        # Back up data/ directory
make setup         # Run hub setup script (on Ubuntu)
make signin-codex  # Codex device login via Docker
make signin-claude # Claude login via Docker (interactive)
make clean         # Stop and remove containers (keeps data/)
```

---

## Risk Acknowledgement

Theo's two hard rules:

1. **Do not serve other people's traffic with your subscriptions.**
2. **Only use Claude models through Claude Code over the proxy.**

See [`NOTICE.md`](NOTICE.md) for the full legal disclaimer and [`CREDITS.md`](CREDITS.md) for attribution.

---

## Support

This is a personal setup repository adapted from Theo's public guide. There is no official support. Open issues for bugs in the repo files, not for account bans or provider issues.
