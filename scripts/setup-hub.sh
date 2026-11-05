#!/usr/bin/env bash
#
# setup-hub.sh — Prepare an Ubuntu home server for CLIProxyAPI in Docker.
# Run this on the HUB machine (your always-on Ubuntu box).
#
# Usage: curl -fsSL ... | bash   or   ./setup-hub.sh
#
set -euo pipefail

echo "=== cliproxy hub setup ==="

# 1. OS check
echo "[1/7] OS check..."
uname -a
if ! grep -qi ubuntu /etc/os-release 2>/dev/null; then
  echo "Warning: expected Ubuntu. Continuing anyway."
fi

# 2. Datacenter check — must NOT be a cloud host
echo "[2/7] Datacenter check..."
ORG=$(curl -s --max-time 10 https://ipinfo.io/org || echo "unknown")
echo "Org: $ORG"
if echo "$ORG" | grep -qiE "amazon|aws|hetzner|digitalocean|ovh|google|microsoft|azure|linode|vultr"; then
  echo "ERROR: This appears to be a datacenter/VPS IP. Do not sign in here."
  exit 1
fi

# 3. Docker check / install
echo "[3/7] Docker check..."
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found. Installing Docker..."
  curl -fsSL https://get.docker.com | sh
  sudo usermod -aG docker "$USER"
  echo "Please log out and back in for Docker group membership, then re-run this script."
  exit 0
fi
docker --version

# 4. Port 8317 free
echo "[4/7] Port 8317 check..."
if ss -ltn 2>/dev/null | grep -q ':8317'; then
  echo "ERROR: Port 8317 is already in use."
  ss -ltn | grep ':8317'
  exit 1
fi
echo "Port 8317 is free."

# 5. Disable sleep
echo "[5/7] Disabling sleep/suspend targets..."
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true
sudo systemctl disable sleep.target suspend.target hibernate.target hybrid-sleep.target 2>/dev/null || true
echo "Sleep targets masked."

# 6. Create directory and copy configs
echo "[6/6] Creating ~/cliproxyapi..."
mkdir -p ~/cliproxyapi/{config,data}
cp config/config.yaml.example ~/cliproxyapi/config/config.yaml
cp docker/docker-compose.yml ~/cliproxyapi/docker-compose.yml
cp .env.example ~/cliproxyapi/.env

echo ""
echo "=== NEXT STEPS ==="
echo "1. Edit ~/cliproxyapi/.env — set CLIPROXY_ACCESS_KEY and CLIPROXY_MANAGEMENT_KEY"
echo "2. Edit ~/cliproxyapi/config/config.yaml if needed"
echo "3. cd ~/cliproxyapi && docker compose up -d"
echo "4. Set up Cloudflare Tunnel to http://127.0.0.1:8317"
echo "5. Run sign-ins: ./scripts/signin-codex.sh (and claude login manually)"
echo ""
echo "Done. Hub is ready for configuration."
