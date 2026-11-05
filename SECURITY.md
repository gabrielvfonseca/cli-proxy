# Security Policy

## ⚠️ Read NOTICE.md First

This repository is provided **"as is"** without warranty. See [`NOTICE.md`](NOTICE.md) for the full legal disclaimer, liability waiver, and account ban risk acknowledgment.

## Supported Versions

The latest release of this setup is supported. Older versions may not reflect current CLIProxyAPI config versions or Docker image changes.

## Reporting a Vulnerability

If you discover a security issue in this repository's configuration or scripts, please disclose it responsibly. **Do not open a public issue** for security vulnerabilities.

## Secrets Handling

| Secret | Purpose | Risk if Exposed |
|--------|---------|-----------------|
| `CLIPROXY_ACCESS_KEY` | Sent by all clients (Claude Code, Codex, OpenCode, Zed) | Attacker can route requests through your accounts, consume your tokens/quota |
| `CLIPROXY_MANAGEMENT_KEY` | Protects `/management.html` panel | Attacker can view/modify your accounts, disable/enable providers |
| Auth state in `data/` | OAuth tokens, session cookies for your Claude/Codex accounts | Full account compromise |

### Rules

1. **Never commit `.env`, `config.yaml` with real keys, or `data/` to version control.**
2. `.env.example` and `config/config.yaml.example` contain placeholders only.
3. Generate strong random keys: `openssl rand -hex 32`
4. Rotate credentials immediately if they are ever exposed.
5. Restrict file permissions: `chmod 600 .env config/config.yaml`

## Network Security

- The Docker container binds to `127.0.0.1:8317` only (not `0.0.0.0` on the host). Cloudflare Tunnel is the front door.
- Cloudflare Tunnel restricts access to authorized viewers of the tunnel.
- Do not expose port 8317 directly to the internet.

## Risk Acknowledgement

Using this setup:

- **May violate Terms of Service** of Anthropic, OpenAI, or other providers
- **May result in account suspension or permanent banning**
- Is done **entirely at your own risk**

Theo's two hard rules:

1. **Do not serve other people's traffic with your subscriptions.**
2. **Only use Claude models through Claude Code over the proxy.**

## Third-Party Dependencies

This repo configures third-party software, each subject to its own license and terms:

- **CLIProxyAPI** — https://github.com/router-for-me/CLIProxyAPI
- **Docker** — https://www.docker.com/
- **Cloudflare Tunnel / cloudflared** — https://www.cloudflare.com/products/tunnel/
- **Claude Code** — Anthropic
- **Codex** — OpenAI
- **OpenCode**
- **Zed**

## Attribution

Original concept and guide by **Theo (theo4gg)**. See [`CREDITS.md`](CREDITS.md).
