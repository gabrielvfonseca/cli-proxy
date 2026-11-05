# Credits & Attribution

## Original Guide Author

**Theo (theo4gg)**

The setup described in this repository is based on Theo's public guide and video:

> **"How I manage 7 Claude and 3 Codex accounts across 12+ computers"**  
> YouTube: https://www.youtube.com/watch?v=D8PikZ1KhUo

Theo's original guide covers:

- Running CLIProxyAPI on one always-online home computer
- Keeping Claude and Codex auth fresh from a single location
- Using Tailscale to link client machines to the hub
- Pointing Claude Code, Codex, and T3 Code at the hub endpoint
- Session affinity, Codex websockets, and routing considerations
- Risk warnings and two hard rules for responsible use

Theo has explicitly stated:

> *"I'll guide you through the setup. First, a few questions."*  
> *"Warning: Theo has never had an account banned doing this, but there's always a risk. Don't blame him if an account gets banned."*  
> *"Two hard rules from me: (1) Do not serve other people's traffic with your subs. (2) Only ever use Claude models through your Claude subs in Claude Code over the proxy."*

## CLIProxyAPI

**router-for-me**  
GitHub: https://github.com/router-for-me/CLIProxyAPI  
Docs: https://help.router-for.me/

The actual proxy software that this repository deploys in Docker.

## Docker Image

**eceasy**  
Image: `eceasy/cli-proxy-api:latest`

## Cloudflare Tunnel

**Cloudflare**  
Product: Cloudflare Tunnel (`cloudflared`)  
https://www.cloudflare.com/products/tunnel/

## Tools Supported Through the Hub

- **Claude Code** — Anthropic
- **Codex** — OpenAI
- **OpenCode**
- **Zed**

## Repository Maintainer

This adaptation (Docker + Cloudflare Tunnel + second config dirs + scripts) was assembled for personal use based on Theo's public guide. All original concepts, configuration values, and risk warnings belong to Theo.

## Trademarks

Claude, Claude Code, and Anthropic are trademarks of Anthropic, PBC.  
Codex and OpenAI are trademarks of OpenAI, LLC.  
OpenCode is a trademark of its respective owners.  
Zed is a trademark of Zed Industries, Inc.  
Docker is a trademark of Docker, Inc.  
Cloudflare is a trademark of Cloudflare, Inc.

This repository is not affiliated with, endorsed by, or sponsored by any of the above companies or projects.
