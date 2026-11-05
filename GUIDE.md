# Guide — CLIProxyAPI Hub Setup

> Adapted from **Theo (theo4gg)**'s public guide:  
> *"How I manage 7 Claude and 3 Codex accounts across 12+ computers"*  
> YouTube: https://www.youtube.com/watch?v=D8PikZ1KhUo  
>  
> **Full credit goes to Theo for the original concept, configuration, and operational guidance.**  
> See `CREDITS.md` and `NOTICE.md` for attribution and legal disclaimers.

---

## tl;dr

Theo recommends proxying all your Claude and Codex auth through one home computer.

**Why?** Juggling auth across multiple accounts is annoying enough; doing it on multiple computers is hell. Constantly swapping the IP address your traffic comes from is practically begging for a ban.

CLIProxyAPI is the easiest way. You set up one computer that stays on, and every Claude Code and Codex instance uses it as an API instead of the normal login. **Cloudflare Tunnel** is the easiest way to link your other machines to that box (Theo uses Tailscale; this repo adapts for Cloudflare Tunnel).

This lets your shared auth work in Claude Code, Codex, OpenCode, and Zed across all your machines, without signing in on every device and app.

**Warning:** Theo has never had an account banned doing this, but there's always a risk. Don't blame him if an account gets banned. See `NOTICE.md` for the full legal disclaimer.

---

## First: You Need an Always-Online Machine

You need a computer at home that stays on. All the time. If that box is off or asleep, every agent pointed at it stops working.

### Why

- **Claude Code auth breaks every 2–3 days.** You need one place that keeps it fresh for you, not five laptops all fighting over it.
- **You want most of your traffic coming from one place, ideally one residential IP address.** Traffic from a bunch of different computers at the same time is how they can tell something sketchy is going on.
- **Every other machine** (laptops, servers, cloud boxes, whatever) just connects to the hub. The hub is the only thing that talks to Anthropic and OpenAI with your accounts.

### Requirements

- **Not a VPS.** Do not sign in to Claude Code or Codex on a VPS, especially Claude Code. Anthropic is aggressive about sign-ins from datacenter IPs (AWS, Hetzner, all of those).
- **Not over a VPN** (Tailscale/Cloudflare Tunnel is fine — you need that).
- **Must stay awake.** The hub must not sleep.

### Recommended Hardware

An old computer you haven't used in a while, running Ubuntu. It's not doing inference, just running code. 60–80 watts at worst.

---

## The Disclosure Bit (Theo's Words)

This might get you banned. This might be against the terms of service. Theo is just speaking from his experience — don't hold him accountable. If you get banned and Theo didn't, that's unfortunate and he's sorry. You'll probably be fine though.

Across 30+ Claude accounts between Theo and his friends, one friend got banned twice, for dumb stuff. He registered on a VPN with a business card that wasn't his. Temporary, reinstated almost immediately.

### Two Hard Rules from Theo

1. **Do not serve other people's traffic with your subs.** If you use this as an alternative to the API to serve user traffic, you deserve your ban. Abuse the generosity by building cool stuff, not by reselling it.
2. **Only ever use Claude models through your Claude subs in Claude Code over the proxy.** Do not, under any circumstance, use the sub in anything else unless you really, really like dealing with Anthropic support and getting accounts banned.

---

## Setup

### 1. Install It on the Hub Box

This repo uses **Docker** instead of the bare-metal installer. Deploy `docker/docker-compose.yml` (or the root `docker-compose.yml`) to your Ubuntu server.

```bash
# On the hub
mkdir -p ~/cliproxyapi
cd ~/cliproxyapi
# Copy config/, docker/, scripts/, .env.example from this repo
docker compose up -d
```

Or use the Makefile:

```bash
make setup   # runs scripts/setup-hub.sh
make up      # starts the container
```

### 2. Config

Edit `config/config.yaml` (or root `config.yaml`). Copy from the example and set your secrets:

```yaml
config-version: 8
server:
  host: "0.0.0.0"          # 0.0.0.0 inside Docker; Cloudflare Tunnel reaches it
  port: 8317
  trusted-proxies: ["127.0.0.1", "::1"]
management:
  allow-remote: true       # so you can open the panel over Cloudflare Tunnel
  secret-key: "<make one up>"   # never share; never commit
access:
  api-keys:
    - "<your-access-key>"  # what Claude Code, Codex, OpenCode, Zed send
routing:
  strategy: "round-robin"
  session-affinity: true   # Theo's change #1 — ON by default here
  session-affinity-ttl: "1h"
  retry:
    request-retry: 3
    max-retry-interval: 30
```

**Bind it to localhost inside the container** (the publish port is `127.0.0.1:8317:8317`). Cloudflare Tunnel is the front door.

### 3. Run It Always-On

Docker container with `restart: unless-stopped`. Optionally install the systemd unit:

```bash
sudo cp systemd/cliproxyapi.service /etc/systemd/user/cliproxyapi.service
systemctl --user enable --now cliproxyapi
loginctl enable-linger
```

Or just rely on Docker's restart policy.

### 4. Sign Your Accounts In (on the Hub Box)

Run these on the hub, **not** on your laptop:

```bash
# Codex (device code — easiest on a headless box)
docker run --rm -it -v "$HOME/cliproxyapi/data:/app/data" \
  eceasy/cli-proxy-api:latest -codex-device-login

# Claude (browser flow)
docker run --rm -it -v "$HOME/cliproxyapi/data:/app/data" \
  eceasy/cli-proxy-api:latest -claude-login
```

**Headless Claude login:** The OAuth callback lands on port 54545 on the hub, and your browser isn't on the hub. Fix: from your laptop, open a tunnel first:

```bash
ssh -L 54545:localhost:54545 <hub>
```

Then start the login and open the URL it gives you. Add `-no-browser` to print the URL instead of launching a browser. Codex's browser callback is port 1455 if you go that route — same tunnel trick.

Repeat per account. Then open the management panel at `https://<your-tunnel-url>/management.html` and confirm everything showed up. There's also a `-tui` flag if you want to manage it from the terminal.

### 5. Put Cloudflare Tunnel in Front of It

Theo uses Tailscale. This repo uses **Cloudflare Tunnel** instead.

Install `cloudflared` on the hub, then:

```bash
# Quick tunnel (ephemeral URL)
cloudflared tunnel --url http://localhost:8317

# Or named tunnel (persistent URL)
cloudflared tunnel create cliproxy
cloudflared tunnel route dns cliproxy cliproxy.yourdomain.com
```

Your hub endpoint: `https://<your-tunnel-url>`

Only people with access to the tunnel can hit it. Simple.

### 6. Point Your Tools at It

#### Claude Code — `~/.claude-hub/settings.json`

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

#### Codex — `~/.codex-hub/config.toml`

```toml
model_provider = "cliproxy"

[model_providers.cliproxy]
name = "CLIProxyAPI"
base_url = "https://<your-tunnel-url>/v1"
wire_api = "responses"
requires_openai_auth = false
supports_websockets = true   # Theo's change #3 — ON by default here
experimental_bearer_token = "<your-access-key>"
```

```bash
CODEX_HOME=~/.codex-hub codex
```

#### OpenCode

```bash
export ANTHROPIC_BASE_URL="https://<your-tunnel-url>"
export ANTHROPIC_AUTH_TOKEN="<your-access-key>"
```

#### Zed

Add a custom Anthropic provider:
- Base URL: `https://<your-tunnel-url>`
- API Key: `<your-access-key>`

**Want to keep your normal install untouched?** Use second config dirs (`~/.claude-hub`, `~/.codex-hub`) as shown above. Or point your normal `~/.claude/settings.json` and `~/.codex/config.toml` directly.

---

## Things Theo Changed (Your First Token Maxing Tasks)

From Theo's guide, these are the customizations he made beyond stock CLIProxyAPI:

### 1. Session Affinity

Already in the config above (`session-affinity: true`). Caches are account-specific. If a thread hops accounts per prompt, you eat cache writes for no reason. Keep an eye on cache read/write numbers. If writes look crazy, your affinity is broken.

### 2. Soonest-Reset-First Routing

By default CLIProxyAPI spreads traffic evenly across accounts. Theo considers this dumb. If one account resets tomorrow at 1pm and another resets in 4 days, he wants to burn the one that resets tomorrow. Whatever is left when a reset hits is money you lost.

> **This is NOT in upstream CLIProxyAPI.** Upstream has per-account `priority` and `weight`, which isn't the same thing. Theo had an agent build it. You should too.

This repository does **not** include soonest-reset-first routing because it's not in the public config. It's listed here as a task for you to implement.

### 3. Codex Over Websockets

Codex subs don't use websockets through the proxy by default. Theo turned on `supports_websockets` in the Codex config. That hugely increases performance. It's a little annoying to get right, but worth it. Already enabled in `clients/codex/config.toml.example`.

---

## When Stuff Breaks

- **Need to bench an account?** Set `"disabled": true` in its auth JSON in `~/.cli-proxy-api`. It drops out of rotation with no restart.
- **Codex says `token_invalidated` (401)?** That grant is dead. Rerun the device login on the hub:
  ```bash
  docker run --rm -it -v "$HOME/cliproxyapi/data:/app/data" \
    eceasy/cli-proxy-api:latest -codex-device-login
  ```
- **If only one account is enabled for a provider**, a limit hit has nowhere else to go. Add a second if you can.
- **Mac client can't resolve `*.ts.net` names** (if you use Tailscale instead of Cloudflare Tunnel):
  ```bash
  sudo mkdir -p /etc/resolver && echo "nameserver 100.100.100.100" | sudo tee /etc/resolver/<tailnet>.ts.net
  ```

---

## Verify From Another Machine

```bash
curl -s https://<your-tunnel-url>/v1/models \
  -H "Authorization: Bearer <your-access-key>" | head -c 300
```

Should return a JSON model list.

---

## One Last Thing (Theo)

> "Now go burn your tokens before they reset 💀"

---

## See Also

- `CREDITS.md` — Full attribution to Theo and third-party projects
- `NOTICE.md` — Legal disclaimer and liability waiver
- `PLAN.md` — Step-by-step deployment checklist
- `README.md` — Quick start and file reference
- `SECURITY.md` — Security policy and secrets handling
