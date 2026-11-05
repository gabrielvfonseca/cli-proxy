# NOTICE — Legal Disclaimer & Liability Waiver

## ⚠️ Important: Read Before Using

This repository contains configuration files, scripts, and documentation for deploying **CLIProxyAPI** — a self-hosted proxy for Claude and Codex authentication — as described in a public guide by **Theo (theo4gg)**.

By using any file, script, or configuration in this repository, you agree to the following:

### 1. No Warranty

This software and documentation is provided **"as is"**, without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose, and noninfringement. The maintainers and contributors make no guarantees that this setup will work as intended, that your accounts will remain active, or that any specific outcome will be achieved.

### 2. No Liability

To the maximum extent permitted by law, the maintainers, contributors, and any person associated with this repository shall **not be liable** for any claim, damages, or other liability arising from:

- Use of this software or documentation
- Suspension, termination, or banning of any Claude, Codex, OpenAI, or Anthropic account
- Loss of tokens, credits, quotas, or subscription value
- Data loss, data corruption, or exposure of authentication credentials
- Any violation of Terms of Service, acceptable use policies, or applicable laws
- Any indirect, incidental, special, exemplary, or consequential damages

### 3. Account Ban Risk

Using this setup to proxy Claude or Codex authentication through a self-hosted server:

- **May violate Terms of Service** of Anthropic, OpenAI, or other providers
- **May result in account suspension or permanent banning**
- Is done **entirely at your own risk**

Theo (theo4gg) has stated publicly that he has never had an account banned doing this, but explicitly warns: *"There's always a risk. Don't blame him if an account gets banned."* The same warning applies here — **do not blame the maintainers if an account gets banned.**

### 4. Two Hard Rules

If you use this setup, you must abide by these rules:

1. **Do not serve other people's traffic with your subscriptions.** If you use this as an alternative to the API to serve user traffic, you deserve your ban. Do not resell access or abuse the generosity of your subscriptions by building infrastructure for others.

2. **Only use Claude models through your Claude subscriptions in Claude Code over the proxy.** Do not, under any circumstance, use the subscription in anything else unless you are prepared to deal with Anthropic support and potentially banned accounts.

### 5. Credentials & Secrets

You are solely responsible for:

- Generating and protecting your own access keys and management keys
- Never committing real credentials to version control
- Rotating credentials if they are ever exposed
- Securing the machine that runs the proxy (your "hub")

### 6. Compliance with Laws

You are responsible for ensuring that your use of this setup complies with all applicable laws, regulations, and Terms of Service in your jurisdiction. The maintainers do not condone or encourage violations of any provider's Terms of Service.

### 7. Third-Party Software

This repository references and configures third-party software including:

- **CLIProxyAPI** by router-for-me (https://github.com/router-for-me/CLIProxyAPI)
- **Docker** (https://www.docker.com/)
- **Cloudflare Tunnel / cloudflared** (https://www.cloudflare.com/products/tunnel/)
- **Claude Code** by Anthropic
- **Codex** by OpenAI
- **OpenCode**
- **Zed**

Each of these is subject to its own license and terms of service. The maintainers of this repository are not affiliated with any of these projects.

### 8. Attribution

The original setup concept and guide are by **Theo (theo4gg)**, shared in a public video and written guide. This repository adapts that guide for deployment with Docker and Cloudflare Tunnel. Full credit goes to Theo for the original idea, configuration values, and operational guidance.

---

## Summary

**You use this repository at your own risk. The maintainers accept no responsibility for account bans, Terms of Service violations, lost tokens, or any other consequence arising from your use of this software.**

If you do not agree with these terms, do not use this repository.
